library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity nco is
  generic(
    dig_size    : natural := 16;
    acc_size    : natural := 16;
    quant_size  : natural := 12;
    F_s         : natural := 44100
  );
  port(
    clk       : in std_logic;
    Rs        : in std_logic;
    phase_inc : in std_logic_vector(acc_size-1 downto 0);
    sin_out   : out std_logic_vector(dig_size-1 downto 0)
  );
end nco;


architecture nco_arch of nco is
    subtype val_type is integer range -2**(dig_size-1) to 2**(dig_size-1) - 1;
    constant TABLE_SIZE : integer := 2**quant_size/4;

    type table_array is array (0 to TABLE_SIZE-1) of val_type;

    constant LUT : table_array := (
          0,     50,    100,    150,    201,    251,    301,    351,    402,    452,    502,    552,    603,
        653,    703,    753,    804,    854,    904,    954,   1005,   1055,   1105,   1155,   1206,   1256,
       1306,   1356,   1407,   1457,   1507,   1557,   1607,   1658,   1708,   1758,   1808,   1858,   1909,
       1959,   2009,   2059,   2109,   2159,   2210,   2260,   2310,   2360,   2410,   2460,   2510,   2560,
       2611,   2661,   2711,   2761,   2811,   2861,   2911,   2961,   3011,   3061,   3111,   3161,   3211,
       3261,   3311,   3361,   3411,   3461,   3511,   3561,   3611,   3661,   3711,   3761,   3811,   3861,
       3911,   3961,   4011,   4061,   4110,   4160,   4210,   4260,   4310,   4360,   4409,   4459,   4509,
       4559,   4609,   4658,   4708,   4758,   4808,   4857,   4907,   4957,   5006,   5056,   5106,   5155,
       5205,   5255,   5304,   5354,   5403,   5453,   5503,   5552,   5602,   5651,   5701,   5750,   5800,
       5849,   5898,   5948,   5997,   6047,   6096,   6146,   6195,   6244,   6294,   6343,   6392,   6442,
       6491,   6540,   6589,   6639,   6688,   6737,   6786,   6835,   6884,   6934,   6983,   7032,   7081,
       7130,   7179,   7228,   7277,   7326,   7375,   7424,   7473,   7522,   7571,   7620,   7669,   7717,
       7766,   7815,   7864,   7913,   7961,   8010,   8059,   8108,   8156,   8205,   8254,   8302,   8351,
       8400,   8448,   8497,   8545,   8594,   8642,   8691,   8739,   8788,   8836,   8884,   8933,   8981,
       9029,   9078,   9126,   9174,   9223,   9271,   9319,   9367,   9415,   9463,   9512,   9560,   9608,
       9656,   9704,   9752,   9800,   9848,   9896,   9944,   9991,  10039,  10087,  10135,  10183,  10230,
      10278,  10326,  10374,  10421,  10469,  10517,  10564,  10612,  10659,  10707,  10754,  10802,  10849,
      10897,  10944,  10991,  11039,  11086,  11133,  11181,  11228,  11275,  11322,  11369,  11416,  11464,
      11511,  11558,  11605,  11652,  11699,  11746,  11793,  11839,  11886,  11933,  11980,  12027,  12073,
      12120,  12167,  12213,  12260,  12307,  12353,  12400,  12446,  12493,  12539,  12586,  12632,  12678,
      12725,  12771,  12817,  12864,  12910,  12956,  13002,  13048,  13094,  13140,  13186,  13232,  13278,
      13324,  13370,  13416,  13462,  13508,  13554,  13599,  13645,  13691,  13736,  13782,  13828,  13873,
      13919,  13964,  14010,  14055,  14100,  14146,  14191,  14236,  14282,  14327,  14372,  14417,  14462,
      14507,  14552,  14598,  14642,  14687,  14732,  14777,  14822,  14867,  14912,  14956,  15001,  15046,
      15090,  15135,  15180,  15224,  15269,  15313,  15357,  15402,  15446,  15491,  15535,  15579,  15623,
      15667,  15712,  15756,  15800,  15844,  15888,  15932,  15976,  16019,  16063,  16107,  16151,  16195,
      16238,  16282,  16325,  16369,  16413,  16456,  16499,  16543,  16586,  16630,  16673,  16716,  16759,
      16802,  16846,  16889,  16932,  16975,  17018,  17061,  17104,  17146,  17189,  17232,  17275,  17317,
      17360,  17403,  17445,  17488,  17530,  17573,  17615,  17658,  17700,  17742,  17784,  17827,  17869,
      17911,  17953,  17995,  18037,  18079,  18121,  18163,  18204,  18246,  18288,  18330,  18371,  18413,
      18454,  18496,  18537,  18579,  18620,  18662,  18703,  18744,  18785,  18826,  18868,  18909,  18950,
      18991,  19032,  19073,  19113,  19154,  19195,  19236,  19276,  19317,  19358,  19398,  19439,  19479,
      19519,  19560,  19600,  19640,  19681,  19721,  19761,  19801,  19841,  19881,  19921,  19961,  20001,
      20040,  20080,  20120,  20159,  20199,  20239,  20278,  20318,  20357,  20396,  20436,  20475,  20514,
      20553,  20592,  20631,  20671,  20709,  20748,  20787,  20826,  20865,  20904,  20942,  20981,  21020,
      21058,  21097,  21135,  21173,  21212,  21250,  21288,  21326,  21365,  21403,  21441,  21479,  21517,
      21555,  21592,  21630,  21668,  21706,  21743,  21781,  21818,  21856,  21893,  21931,  21968,  22005,
      22042,  22080,  22117,  22154,  22191,  22228,  22265,  22301,  22338,  22375,  22412,  22448,  22485,
      22521,  22558,  22594,  22631,  22667,  22703,  22740,  22776,  22812,  22848,  22884,  22920,  22956,
      22992,  23027,  23063,  23099,  23134,  23170,  23205,  23241,  23276,  23312,  23347,  23382,  23417,
      23453,  23488,  23523,  23558,  23593,  23627,  23662,  23697,  23732,  23766,  23801,  23835,  23870,
      23904,  23939,  23973,  24007,  24041,  24075,  24109,  24144,  24177,  24211,  24245,  24279,  24313,
      24346,  24380,  24414,  24447,  24480,  24514,  24547,  24580,  24614,  24647,  24680,  24713,  24746,
      24779,  24812,  24845,  24877,  24910,  24943,  24975,  25008,  25040,  25073,  25105,  25137,  25169,
      25201,  25234,  25266,  25298,  25330,  25361,  25393,  25425,  25457,  25488,  25520,  25551,  25583,
      25614,  25645,  25677,  25708,  25739,  25770,  25801,  25832,  25863,  25894,  25925,  25955,  25986,
      26016,  26047,  26077,  26108,  26138,  26169,  26199,  26229,  26259,  26289,  26319,  26349,  26379,
      26409,  26438,  26468,  26498,  26527,  26557,  26586,  26615,  26645,  26674,  26703,  26732,  26761,
      26790,  26819,  26848,  26877,  26905,  26934,  26963,  26991,  27020,  27048,  27076,  27105,  27133,
      27161,  27189,  27217,  27245,  27273,  27301,  27329,  27356,  27384,  27411,  27439,  27466,  27494,
      27521,  27548,  27576,  27603,  27630,  27657,  27684,  27711,  27737,  27764,  27791,  27817,  27844,
      27870,  27897,  27923,  27949,  27976,  28002,  28028,  28054,  28080,  28106,  28131,  28157,  28183,
      28208,  28234,  28259,  28285,  28310,  28335,  28361,  28386,  28411,  28436,  28461,  28486,  28511,
      28535,  28560,  28585,  28609,  28634,  28658,  28682,  28707,  28731,  28755,  28779,  28803,  28827,
      28851,  28875,  28898,  28922,  28946,  28969,  28993,  29016,  29039,  29062,  29086,  29109,  29132,
      29155,  29178,  29201,  29223,  29246,  29269,  29291,  29314,  29336,  29359,  29381,  29403,  29425,
      29447,  29469,  29491,  29513,  29535,  29557,  29578,  29600,  29621,  29643,  29664,  29686,  29707,
      29728,  29749,  29770,  29791,  29812,  29833,  29854,  29874,  29895,  29915,  29936,  29956,  29977,
      29997,  30017,  30037,  30057,  30077,  30097,  30117,  30137,  30156,  30176,  30196,  30215,  30235,
      30254,  30273,  30292,  30312,  30331,  30350,  30368,  30387,  30406,  30425,  30443,  30462,  30480,
      30499,  30517,  30535,  30554,  30572,  30590,  30608,  30626,  30644,  30661,  30679,  30697,  30714,
      30732,  30749,  30766,  30784,  30801,  30818,  30835,  30852,  30869,  30886,  30902,  30919,  30936,
      30952,  30969,  30985,  31001,  31018,  31034,  31050,  31066,  31082,  31098,  31114,  31129,  31145,
      31161,  31176,  31192,  31207,  31222,  31237,  31253,  31268,  31283,  31298,  31312,  31327,  31342,
      31357,  31371,  31386,  31400,  31414,  31429,  31443,  31457,  31471,  31485,  31499,  31513,  31526,
      31540,  31554,  31567,  31581,  31594,  31607,  31620,  31634,  31647,  31660,  31673,  31685,  31698,
      31711,  31723,  31736,  31749,  31761,  31773,  31785,  31798,  31810,  31822,  31834,  31846,  31857,
      31869,  31881,  31892,  31904,  31915,  31927,  31938,  31949,  31960,  31971,  31982,  31993,  32004,
      32015,  32025,  32036,  32047,  32057,  32067,  32078,  32088,  32098,  32108,  32118,  32128,  32138,
      32148,  32157,  32167,  32176,  32186,  32195,  32205,  32214,  32223,  32232,  32241,  32250,  32259,
      32268,  32276,  32285,  32294,  32302,  32311,  32319,  32327,  32335,  32343,  32351,  32359,  32367,
      32375,  32383,  32390,  32398,  32405,  32413,  32420,  32427,  32435,  32442,  32449,  32456,  32463,
      32469,  32476,  32483,  32489,  32496,  32502,  32509,  32515,  32521,  32527,  32533,  32539,  32545,
      32551,  32557,  32562,  32568,  32573,  32579,  32584,  32589,  32595,  32600,  32605,  32610,  32615,
      32619,  32624,  32629,  32633,  32638,  32642,  32647,  32651,  32655,  32659,  32663,  32667,  32671,
      32675,  32679,  32682,  32686,  32689,  32693,  32696,  32700,  32703,  32706,  32709,  32712,  32715,
      32718,  32720,  32723,  32726,  32728,  32730,  32733,  32735,  32737,  32739,  32741,  32743,  32745,
      32747,  32749,  32750,  32752,  32754,  32755,  32756,  32758,  32759,  32760,  32761,  32762,  32763,
      32764,  32764,  32765,  32766,  32766,  32767,  32767,  32767,  32767,  32767
    );
  begin
    sin_gen: process(clk, Rs)
        variable acc    : unsigned(acc_size-1 downto 0) := to_unsigned(0, acc_size);
        variable addr   : unsigned(quant_size-1 downto 0);
      begin 
        if (Rs = '1') then
            acc := to_unsigned(0, acc_size);
            addr := to_unsigned(0, quant_size);
            sin_out <= std_logic_vector(to_signed(0, dig_size));
        elsif (rising_edge(clk)) then
            addr := acc(acc_size-1 downto acc_size - quant_size);       --quantization
            acc  := acc + unsigned(phase_inc);

            if (to_integer(addr) < TABLE_SIZE) then
                sin_out <= std_logic_vector(
                    to_signed(LUT(to_integer(addr)), 
                              dig_size));
            elsif (to_integer(addr) = TABLE_SIZE) then
                sin_out <= std_logic_vector(
                    to_signed(2**(dig_size-1) - 1, dig_size));
            elsif (to_integer(addr) > TABLE_SIZE and to_integer(addr) < 2*TABLE_SIZE) then
                sin_out <= std_logic_vector(
                    to_signed(LUT(2*TABLE_SIZE - to_integer(addr)), 
                              dig_size));
            elsif (to_integer(addr) >= 2*TABLE_SIZE and to_integer(addr) < 3*TABLE_SIZE) then
                sin_out <= std_logic_vector(
                    to_signed(-LUT(to_integer(addr) - 2*TABLE_SIZE), 
                              dig_size));
            elsif (to_integer(addr) = 3*TABLE_SIZE) then
                sin_out <= std_logic_vector(
                    to_signed(-(2**(dig_size-1) - 1), dig_size));
            elsif (to_integer(addr) > 3*TABLE_SIZE) then
                sin_out <= std_logic_vector(
                    to_signed(-LUT(4*TABLE_SIZE - to_integer(addr)), 
                              dig_size));
            end if;
        end if;
    end process;
end nco_arch;