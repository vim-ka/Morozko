CREATE PROCEDURE Guard.PrepareQvart4Remove @FastCalc BIT=0
AS
begin

-- ЧАСТЬ РАСЧЕТА УЖЕ ВЫПОЛНЕНА, ПРОПУСКАЕМ ЕЕ ДЛЯ СКОРОСТИ...
  IF @FastCalc=0 begin
    IF OBJECT_ID('guard.qvart4remove') IS NOT NULL DROP TABLE guard.qvart4remove;
  
    CREATE TABLE guard.qvart4remove (hitag INT, SC DECIMAL(10,2), kol DECIMAL(10,3), 
      flgweight BIT, cost DECIMAL(12,4), id INT, SaleNvId int, SaleDatnom INT, B_ID INT, backdatnom INT, BackNvId INT,
      Ncom INT, Ncod int);
  
    -- Заполнение исходными данными, из "y:\Папка Обмена\ФИН\Рестория_остатки_ 41_01.xlsx" 
    insert into guard.qvart4remove (hitag, SC, kol) values(6977, 182559.35, 321.354);
    insert into guard.qvart4remove (hitag, SC, kol) values(11668, 310.58, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(12266, 2167.53, 28.05);
    insert into guard.qvart4remove (hitag, SC, kol) values(12468, 2348.99, 29.7);
    insert into guard.qvart4remove (hitag, SC, kol) values(12557, 1234.9, 15.981);
    insert into guard.qvart4remove (hitag, SC, kol) values(13078, 439.50, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(13622, 493.77, 3);
    insert into guard.qvart4remove (hitag, SC, kol) values(13967, 421.89, 3);
    insert into guard.qvart4remove (hitag, SC, kol) values(14035, 378.27, 3);
    insert into guard.qvart4remove (hitag, SC, kol) values(14181, 310.92, 9);
    insert into guard.qvart4remove (hitag, SC, kol) values(14706, 1821.39, 3);
    insert into guard.qvart4remove (hitag, SC, kol) values(14876, 7068.14, 53);
    insert into guard.qvart4remove (hitag, SC, kol) values(14881, 4083.47, 14);
    insert into guard.qvart4remove (hitag, SC, kol) values(14882, 41790.60, 245);
    insert into guard.qvart4remove (hitag, SC, kol) values(14886, 444.63, 4);
    insert into guard.qvart4remove (hitag, SC, kol) values(14893, 14159.80, 154);
    insert into guard.qvart4remove (hitag, SC, kol) values(14896, 1405.00, 22);
    insert into guard.qvart4remove (hitag, SC, kol) values(15204, 3284.93, 39.707);
    insert into guard.qvart4remove (hitag, SC, kol) values(15280, 592.38, 3);
    insert into guard.qvart4remove (hitag, SC, kol) values(15415, 848.24, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(15468, 496.44, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(15492, 5238.29, 10);
    insert into guard.qvart4remove (hitag, SC, kol) values(15778, 93176.54, 152.6);
    insert into guard.qvart4remove (hitag, SC, kol) values(16457, 2542.37, 20);
    insert into guard.qvart4remove (hitag, SC, kol) values(16676, 325.44, 7);
    insert into guard.qvart4remove (hitag, SC, kol) values(16918, 444.11, 12);
    insert into guard.qvart4remove (hitag, SC, kol) values(17601, 516.44, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(19185, 4759.08, 51);
    insert into guard.qvart4remove (hitag, SC, kol) values(19209, 7542.19, 49);
    insert into guard.qvart4remove (hitag, SC, kol) values(19431, 436.00, 10);
    insert into guard.qvart4remove (hitag, SC, kol) values(19734, 1888.35, 10);
    insert into guard.qvart4remove (hitag, SC, kol) values(19791, 396.36, 127);
    insert into guard.qvart4remove (hitag, SC, kol) values(19879, 321.96, 6);
    insert into guard.qvart4remove (hitag, SC, kol) values(19880, 37835.94, 198);
    insert into guard.qvart4remove (hitag, SC, kol) values(21367, 768.81, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(21369, 2599.29, 4);
    insert into guard.qvart4remove (hitag, SC, kol) values(21370, 915.24, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(21540, 5683.46, 8);
    insert into guard.qvart4remove (hitag, SC, kol) values(21872, 4569.01, 55);
    insert into guard.qvart4remove (hitag, SC, kol) values(22129, 2923.62, 6);
    insert into guard.qvart4remove (hitag, SC, kol) values(22354, 459.56, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(22516, 532.09, 30);
    insert into guard.qvart4remove (hitag, SC, kol) values(22581, 714.13, 3);
    insert into guard.qvart4remove (hitag, SC, kol) values(23041, 3093.52, 63);
    insert into guard.qvart4remove (hitag, SC, kol) values(23079, 245.31, 1.012);
    insert into guard.qvart4remove (hitag, SC, kol) values(23080, 269.48, 1.116);
    insert into guard.qvart4remove (hitag, SC, kol) values(23177, 5756.66, 25.846);
    insert into guard.qvart4remove (hitag, SC, kol) values(23213, 1518.71, 11);
    insert into guard.qvart4remove (hitag, SC, kol) values(23214, 3688.59, 29);
    insert into guard.qvart4remove (hitag, SC, kol) values(23215, 3873.82, 27);
    insert into guard.qvart4remove (hitag, SC, kol) values(23254, 419.53, 3.472);
    insert into guard.qvart4remove (hitag, SC, kol) values(23381, 14.04, 0.031);
    insert into guard.qvart4remove (hitag, SC, kol) values(23427, 17583.64, 85.537);
    insert into guard.qvart4remove (hitag, SC, kol) values(23778, 465.31, 2);
    insert into guard.qvart4remove (hitag, SC, kol) values(24038, 317.30, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(24108, 686.44, 10);
    insert into guard.qvart4remove (hitag, SC, kol) values(24115, 636.61, 10);
    insert into guard.qvart4remove (hitag, SC, kol) values(24136, 3413.71, 8.215);
    insert into guard.qvart4remove (hitag, SC, kol) values(24182, 2769.29, 4);
    insert into guard.qvart4remove (hitag, SC, kol) values(24213, 536.02, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(24221, 632.45, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(24222, 672.04, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(24230, 846.61, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(24231, 1430.56, 2);
    insert into guard.qvart4remove (hitag, SC, kol) values(24232, 846.61, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(24276, 508.35, 2);
    insert into guard.qvart4remove (hitag, SC, kol) values(24606, 833.96, 9.792);
    insert into guard.qvart4remove (hitag, SC, kol) values(24685, 660.42, 2);
    insert into guard.qvart4remove (hitag, SC, kol) values(24707, 1582.09, 14.7);
    insert into guard.qvart4remove (hitag, SC, kol) values(24808, 2471.23, 3);
    insert into guard.qvart4remove (hitag, SC, kol) values(24862, 10187.90, 25);
    insert into guard.qvart4remove (hitag, SC, kol) values(25037, 1001.47, 27);
    insert into guard.qvart4remove (hitag, SC, kol) values(25221, 4054.33, 7.458);
    insert into guard.qvart4remove (hitag, SC, kol) values(25265, 2826.54, 62);
    insert into guard.qvart4remove (hitag, SC, kol) values(25411, 16582.58, 64);
    insert into guard.qvart4remove (hitag, SC, kol) values(25528, 1623.12, 9);
    insert into guard.qvart4remove (hitag, SC, kol) values(25531, 1724.72, 16);
    insert into guard.qvart4remove (hitag, SC, kol) values(25547, 430.04, 5);
    insert into guard.qvart4remove (hitag, SC, kol) values(25672, 625.88, 5);
    insert into guard.qvart4remove (hitag, SC, kol) values(25941, 47809.11, 69.221);
    insert into guard.qvart4remove (hitag, SC, kol) values(26060, 12293.93, 21.953);
    insert into guard.qvart4remove (hitag, SC, kol) values(26088, 340.68, 13);
    insert into guard.qvart4remove (hitag, SC, kol) values(26177, 336.36, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(26203, 2291.56, 2);
    insert into guard.qvart4remove (hitag, SC, kol) values(26290, 8596.28, 64.609);
    insert into guard.qvart4remove (hitag, SC, kol) values(26307, 346.84, 9);
    insert into guard.qvart4remove (hitag, SC, kol) values(26341, 0.03, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(26347, 1461.57, 11);
    insert into guard.qvart4remove (hitag, SC, kol) values(26392, 1205.10, 3);
    insert into guard.qvart4remove (hitag, SC, kol) values(26483, 4186.91, 29.149);
    insert into guard.qvart4remove (hitag, SC, kol) values(26499, 430.79, 3.645);
    insert into guard.qvart4remove (hitag, SC, kol) values(26542, 21190.99, 130.956);
    insert into guard.qvart4remove (hitag, SC, kol) values(26646, 1403.48, 52);
    insert into guard.qvart4remove (hitag, SC, kol) values(26647, 2087.61, 77);
    insert into guard.qvart4remove (hitag, SC, kol) values(26736, 780.51, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(26774, 1265.50, 2);
    insert into guard.qvart4remove (hitag, SC, kol) values(26870, 330.33, 3);
    insert into guard.qvart4remove (hitag, SC, kol) values(26989, 7225.25, 86.385);
    insert into guard.qvart4remove (hitag, SC, kol) values(27223, 353.93, 96);
    insert into guard.qvart4remove (hitag, SC, kol) values(27257, 2451.31, 9.95);
    insert into guard.qvart4remove (hitag, SC, kol) values(27276, 1116.91, 5);
    insert into guard.qvart4remove (hitag, SC, kol) values(27432, 340.05, 2);
    insert into guard.qvart4remove (hitag, SC, kol) values(27460, 7225.97, 92);
    insert into guard.qvart4remove (hitag, SC, kol) values(27492, 37563.08, 172.166);
    insert into guard.qvart4remove (hitag, SC, kol) values(27573, 313.45, 0.808);
    insert into guard.qvart4remove (hitag, SC, kol) values(27611, 3727.57, 18.983);
    insert into guard.qvart4remove (hitag, SC, kol) values(27624, 9589.97, 55.569);
    insert into guard.qvart4remove (hitag, SC, kol) values(27641, 2593.68, 11);
    insert into guard.qvart4remove (hitag, SC, kol) values(27886, 815.03, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(27935, 3440.84, 14.836);
    insert into guard.qvart4remove (hitag, SC, kol) values(27979, 377.72, 2);
    insert into guard.qvart4remove (hitag, SC, kol) values(27984, 1253.15, 6.892);
    insert into guard.qvart4remove (hitag, SC, kol) values(28072, 3268.16, 17);
    insert into guard.qvart4remove (hitag, SC, kol) values(28074, 688.76, 4);
    insert into guard.qvart4remove (hitag, SC, kol) values(28114, 585.56, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(28124, 858.51, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(28168, 8773.27, 32);
    insert into guard.qvart4remove (hitag, SC, kol) values(28173, 1272.21, 9);
    insert into guard.qvart4remove (hitag, SC, kol) values(28284, 629.04, 3.642);
    insert into guard.qvart4remove (hitag, SC, kol) values(28476, 223.24, 1.444);
    insert into guard.qvart4remove (hitag, SC, kol) values(28490, 2410.41, 31.603);
    insert into guard.qvart4remove (hitag, SC, kol) values(28577, 674.45, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(28638, 64683.38, 79.507);
    insert into guard.qvart4remove (hitag, SC, kol) values(28672, 677.38, 6);
    insert into guard.qvart4remove (hitag, SC, kol) values(28695, 5181.44, 33.331);
    insert into guard.qvart4remove (hitag, SC, kol) values(29015, 420.69, 4);
    insert into guard.qvart4remove (hitag, SC, kol) values(29139, 932.47, 2);
    insert into guard.qvart4remove (hitag, SC, kol) values(29255, 601.79, 6);
    insert into guard.qvart4remove (hitag, SC, kol) values(29586, 385.64, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(29649, 76132.53, 537.607);
    insert into guard.qvart4remove (hitag, SC, kol) values(29673, 3662.57, 13);
    insert into guard.qvart4remove (hitag, SC, kol) values(29674, 5118.45, 18);
    insert into guard.qvart4remove (hitag, SC, kol) values(29675, 6076.71, 22);
    insert into guard.qvart4remove (hitag, SC, kol) values(29676, 5514.66, 20);
    insert into guard.qvart4remove (hitag, SC, kol) values(29677, 4376.70, 16);
    insert into guard.qvart4remove (hitag, SC, kol) values(29874, 380.25, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(29904, 323.64, 5);
    insert into guard.qvart4remove (hitag, SC, kol) values(30442, 1903.96, 24.111);
    insert into guard.qvart4remove (hitag, SC, kol) values(30592, 3807.46, 4);
    insert into guard.qvart4remove (hitag, SC, kol) values(31818, 122.39, 4);
    insert into guard.qvart4remove (hitag, SC, kol) values(32047, 416.49, 2);
    insert into guard.qvart4remove (hitag, SC, kol) values(32056, 40038.6, 195.744);
    insert into guard.qvart4remove (hitag, SC, kol) values(32059, 578.87, 3.014);
    insert into guard.qvart4remove (hitag, SC, kol) values(32455, 7017.11, 23);
    insert into guard.qvart4remove (hitag, SC, kol) values(32501, 3831.5, 14.685);
    insert into guard.qvart4remove (hitag, SC, kol) values(32596, 5466.1, 61.355);
    insert into guard.qvart4remove (hitag, SC, kol) values(32616, 877.73, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(33327, 174.23, 0.809);
    insert into guard.qvart4remove (hitag, SC, kol) values(33439, 2611.27, 10.678);
    insert into guard.qvart4remove (hitag, SC, kol) values(33446, 451.43, 5);
    insert into guard.qvart4remove (hitag, SC, kol) values(33686, 2306.00, 3);
    insert into guard.qvart4remove (hitag, SC, kol) values(34044, 29600.7, 144.715);
    insert into guard.qvart4remove (hitag, SC, kol) values(34091, 408.71, 0.586);
    insert into guard.qvart4remove (hitag, SC, kol) values(34213, 574.5, 6.939);
    insert into guard.qvart4remove (hitag, SC, kol) values(34403, 918.40, 8);
    insert into guard.qvart4remove (hitag, SC, kol) values(34519, 1107.55, 3.02);
    insert into guard.qvart4remove (hitag, SC, kol) values(34785, 997.96, 2.524);
    insert into guard.qvart4remove (hitag, SC, kol) values(34937, 20701.7, 103.508);
    insert into guard.qvart4remove (hitag, SC, kol) values(34938, 37399.32, 205.696);
    insert into guard.qvart4remove (hitag, SC, kol) values(34992, 2754.54, 5);
    insert into guard.qvart4remove (hitag, SC, kol) values(35174, 4076.26, 24.237);
    insert into guard.qvart4remove (hitag, SC, kol) values(35178, 2884.49, 13);
    insert into guard.qvart4remove (hitag, SC, kol) values(35249, 143282, 865.99);
    insert into guard.qvart4remove (hitag, SC, kol) values(35250, 373879.96, 2723.629);
    insert into guard.qvart4remove (hitag, SC, kol) values(35279, 1365.78, 11.128);
    insert into guard.qvart4remove (hitag, SC, kol) values(35286, 3655.47, 4.327);
    insert into guard.qvart4remove (hitag, SC, kol) values(35358, 461.43, 3);
    insert into guard.qvart4remove (hitag, SC, kol) values(35868, 1511.80, 58);
    insert into guard.qvart4remove (hitag, SC, kol) values(35989, 9690.95, 77.979);
    insert into guard.qvart4remove (hitag, SC, kol) values(36019, 754.55, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(36078, 1177.28, 6);
    insert into guard.qvart4remove (hitag, SC, kol) values(36128, 1674.89, 56);
    insert into guard.qvart4remove (hitag, SC, kol) values(36130, 2382.22, 80);
    insert into guard.qvart4remove (hitag, SC, kol) values(36132, 1281.17, 43);
    insert into guard.qvart4remove (hitag, SC, kol) values(36133, 3130.45, 134);
    insert into guard.qvart4remove (hitag, SC, kol) values(36134, 4927.14, 40.147);
    insert into guard.qvart4remove (hitag, SC, kol) values(36147, 1569.07, 25);
    insert into guard.qvart4remove (hitag, SC, kol) values(36182, 3613.92, 11.468);
    insert into guard.qvart4remove (hitag, SC, kol) values(36378, 377.60, 3);
    insert into guard.qvart4remove (hitag, SC, kol) values(36503, 37226.67, 177.155);
    insert into guard.qvart4remove (hitag, SC, kol) values(36788, 601, 3.313);
    insert into guard.qvart4remove (hitag, SC, kol) values(36802, 2813.92, 6);
    insert into guard.qvart4remove (hitag, SC, kol) values(36803, 1958.76, 4);
    insert into guard.qvart4remove (hitag, SC, kol) values(36833, 313.60, 2);
    insert into guard.qvart4remove (hitag, SC, kol) values(36910, 756.70, 263);
    insert into guard.qvart4remove (hitag, SC, kol) values(36916, 5204.41, 61.558);
    insert into guard.qvart4remove (hitag, SC, kol) values(36919, 17157.73, 22);
    insert into guard.qvart4remove (hitag, SC, kol) values(36952, 908.16, 7);
    insert into guard.qvart4remove (hitag, SC, kol) values(37165, 3436.39, 10);
    insert into guard.qvart4remove (hitag, SC, kol) values(37315, 370.27, 4);
    insert into guard.qvart4remove (hitag, SC, kol) values(37343, 2852.11, 5);
    insert into guard.qvart4remove (hitag, SC, kol) values(37501, 562.56, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(37502, 1169.50, 2);
    insert into guard.qvart4remove (hitag, SC, kol) values(37511, 166.1, 0.8);
    insert into guard.qvart4remove (hitag, SC, kol) values(37512, 5154.08, 51.541);
    insert into guard.qvart4remove (hitag, SC, kol) values(37742, 113572.14, 1049.827);
    insert into guard.qvart4remove (hitag, SC, kol) values(37793, 516.99, 2);
    insert into guard.qvart4remove (hitag, SC, kol) values(37826, 847.84, 28);
    insert into guard.qvart4remove (hitag, SC, kol) values(37869, 2304.02, 11.731);
    insert into guard.qvart4remove (hitag, SC, kol) values(37874, 401.84, 1.482);
    insert into guard.qvart4remove (hitag, SC, kol) values(37967, 3679.2, 17.72);
    insert into guard.qvart4remove (hitag, SC, kol) values(38250, 3543.89, 49);
    insert into guard.qvart4remove (hitag, SC, kol) values(38258, 30444.82, 248.069);
    insert into guard.qvart4remove (hitag, SC, kol) values(38259, 30354.98, 428.083);
    insert into guard.qvart4remove (hitag, SC, kol) values(38260, 1751.11, 20.712);
    insert into guard.qvart4remove (hitag, SC, kol) values(38293, 2514.06, 32.157);
    insert into guard.qvart4remove (hitag, SC, kol) values(38296, 111300.93, 401.413);
    insert into guard.qvart4remove (hitag, SC, kol) values(38414, 311.73, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(38440, 18896.62, 35.394);
    insert into guard.qvart4remove (hitag, SC, kol) values(38450, 2747.88, 31.486);
    insert into guard.qvart4remove (hitag, SC, kol) values(38452, 364.00, 70);
    insert into guard.qvart4remove (hitag, SC, kol) values(38484, 12246.03, 142.546);
    insert into guard.qvart4remove (hitag, SC, kol) values(38500, 43262.55, 194.24);
    insert into guard.qvart4remove (hitag, SC, kol) values(38557, 2644.82, 4.7);
    insert into guard.qvart4remove (hitag, SC, kol) values(38559, 6458.88, 209);
    insert into guard.qvart4remove (hitag, SC, kol) values(38611, 8330.71, 43);
    insert into guard.qvart4remove (hitag, SC, kol) values(38656, 12788.14, 127.881);
    insert into guard.qvart4remove (hitag, SC, kol) values(38695, 1826.25, 59);
    insert into guard.qvart4remove (hitag, SC, kol) values(38696, 2646.93, 85);
    insert into guard.qvart4remove (hitag, SC, kol) values(38698, 559.32, 2);
    insert into guard.qvart4remove (hitag, SC, kol) values(38707, 13462.78, 155.069);
    insert into guard.qvart4remove (hitag, SC, kol) values(38710, 2417, 22.821);
    insert into guard.qvart4remove (hitag, SC, kol) values(38737, 5224.73, 17.416);
    insert into guard.qvart4remove (hitag, SC, kol) values(38753, 1824.79, 3);
    insert into guard.qvart4remove (hitag, SC, kol) values(38785, 615.96, 6);
    insert into guard.qvart4remove (hitag, SC, kol) values(38788, 1415.59, 5);
    insert into guard.qvart4remove (hitag, SC, kol) values(38789, 1748.39, 6);
    insert into guard.qvart4remove (hitag, SC, kol) values(38807, 2064.05, 3);
    insert into guard.qvart4remove (hitag, SC, kol) values(38808, 854.24, 2);
    insert into guard.qvart4remove (hitag, SC, kol) values(38829, 2258.56, 8.748);
    insert into guard.qvart4remove (hitag, SC, kol) values(38830, 17828.85, 73);
    insert into guard.qvart4remove (hitag, SC, kol) values(38839, 192.82, 0.642);
    insert into guard.qvart4remove (hitag, SC, kol) values(38843, 1732.82, 4.9);
    insert into guard.qvart4remove (hitag, SC, kol) values(38845, 981.82, 4);
    insert into guard.qvart4remove (hitag, SC, kol) values(38851, 951.69, 2.246);
    insert into guard.qvart4remove (hitag, SC, kol) values(38853, 1204.29, 7.436);
    insert into guard.qvart4remove (hitag, SC, kol) values(38971, 2993.64, 5.72);
    insert into guard.qvart4remove (hitag, SC, kol) values(38973, 4907.08, 41.843);
    insert into guard.qvart4remove (hitag, SC, kol) values(38991, 1000.00, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(38992, 904.52, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(39034, 98629.16, 179);
    insert into guard.qvart4remove (hitag, SC, kol) values(39035, 1276.29, 5);
    insert into guard.qvart4remove (hitag, SC, kol) values(39059, 859.19, 2.902);
    insert into guard.qvart4remove (hitag, SC, kol) values(39076, 410.24, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(39079, 3741.13, 15);
    insert into guard.qvart4remove (hitag, SC, kol) values(39083, 584.76, 100);
    insert into guard.qvart4remove (hitag, SC, kol) values(39085, 511.19, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(39086, 594.16, 3);
    insert into guard.qvart4remove (hitag, SC, kol) values(39092, 3042.73, 20);
    insert into guard.qvart4remove (hitag, SC, kol) values(39093, 904.97, 5.677);
    insert into guard.qvart4remove (hitag, SC, kol) values(39101, 343.91, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(39156, 2509.75, 6.523);
    insert into guard.qvart4remove (hitag, SC, kol) values(39158, 9749.45, 16.2);
    insert into guard.qvart4remove (hitag, SC, kol) values(39163, 2988.27, 24.318);
    insert into guard.qvart4remove (hitag, SC, kol) values(39169, 2966.09, 2);
    insert into guard.qvart4remove (hitag, SC, kol) values(39182, 855.75, 22);
    insert into guard.qvart4remove (hitag, SC, kol) values(39283, 10943.49, 81.337);
    insert into guard.qvart4remove (hitag, SC, kol) values(39305, 4796.32, 72);
    insert into guard.qvart4remove (hitag, SC, kol) values(39377, 738.86, 3);
    insert into guard.qvart4remove (hitag, SC, kol) values(39379, 314.07, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(39396, 917.35, 3);
    insert into guard.qvart4remove (hitag, SC, kol) values(39410, 1192.79, 250);
    insert into guard.qvart4remove (hitag, SC, kol) values(39411, 4593.75, 32);
    insert into guard.qvart4remove (hitag, SC, kol) values(39419, 475.36, 4);
    insert into guard.qvart4remove (hitag, SC, kol) values(39444, 1317.96, 8.53);
    insert into guard.qvart4remove (hitag, SC, kol) values(39465, 673.37, 23);
    insert into guard.qvart4remove (hitag, SC, kol) values(39473, 5709.90, 19);
    insert into guard.qvart4remove (hitag, SC, kol) values(39479, 874.87, 10.348);
    insert into guard.qvart4remove (hitag, SC, kol) values(39480, 1779.45, 10.357);
    insert into guard.qvart4remove (hitag, SC, kol) values(39485, 1176.51, 12.813);
    insert into guard.qvart4remove (hitag, SC, kol) values(39488, 874.21, 3);
    insert into guard.qvart4remove (hitag, SC, kol) values(39489, 2032.88, 35);
    insert into guard.qvart4remove (hitag, SC, kol) values(39508, 313.95, 46);
    insert into guard.qvart4remove (hitag, SC, kol) values(39509, 1727.55, 4.95);
    insert into guard.qvart4remove (hitag, SC, kol) values(39510, 125590.06, 132.2);
    insert into guard.qvart4remove (hitag, SC, kol) values(39514, 148.07, 0.958);
    insert into guard.qvart4remove (hitag, SC, kol) values(39526, 1001.39, 8);
    insert into guard.qvart4remove (hitag, SC, kol) values(39527, 3181.38, 73);
    insert into guard.qvart4remove (hitag, SC, kol) values(39532, 1525.44, 2.985);
    insert into guard.qvart4remove (hitag, SC, kol) values(39536, 53069.08, 426.102);
    insert into guard.qvart4remove (hitag, SC, kol) values(39558, 406.76, 15);
    insert into guard.qvart4remove (hitag, SC, kol) values(39595, 999.52, 8.5);
    insert into guard.qvart4remove (hitag, SC, kol) values(39606, 4897.86, 144);
    insert into guard.qvart4remove (hitag, SC, kol) values(39618, 2192.02, 11.215);
    insert into guard.qvart4remove (hitag, SC, kol) values(39619, 4970.81, 5.11);
    insert into guard.qvart4remove (hitag, SC, kol) values(39620, 818.24, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(39621, 772.24, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(39622, 1081.15, 2);
    insert into guard.qvart4remove (hitag, SC, kol) values(39630, 10620.71, 61);
    insert into guard.qvart4remove (hitag, SC, kol) values(39633, 423.73, 100);
    insert into guard.qvart4remove (hitag, SC, kol) values(39692, 455.33, 3);
    insert into guard.qvart4remove (hitag, SC, kol) values(39694, 1456.51, 33);
    insert into guard.qvart4remove (hitag, SC, kol) values(39698, 4363.68, 20.425);
    insert into guard.qvart4remove (hitag, SC, kol) values(39701, 932.34, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(39702, 2923.26, 5);
    insert into guard.qvart4remove (hitag, SC, kol) values(39712, 2806.00, 32);
    insert into guard.qvart4remove (hitag, SC, kol) values(39735, 1794.94, 20.355);
    insert into guard.qvart4remove (hitag, SC, kol) values(39738, 933.56, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(39740, 915.27, 4.8);
    insert into guard.qvart4remove (hitag, SC, kol) values(39751, 7789.5, 27);
    insert into guard.qvart4remove (hitag, SC, kol) values(39761, 358.76, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(39808, 561.87, 3);
    insert into guard.qvart4remove (hitag, SC, kol) values(39814, 59198.64, 355.839);
    insert into guard.qvart4remove (hitag, SC, kol) values(39854, 1098.18, 1);
    insert into guard.qvart4remove (hitag, SC, kol) values(39885, 1797.34, 4.225);
    insert into guard.qvart4remove (hitag, SC, kol) values(39889, 5569.44, 10.6);
    insert into guard.qvart4remove (hitag, SC, kol) values(39894, 5311.22, 18);
    insert into guard.qvart4remove (hitag, SC, kol) values(39901, 551.68, 10);
    insert into guard.qvart4remove (hitag, SC, kol) values(39902, 19473.75, 5);
    insert into guard.qvart4remove (hitag, SC, kol) values(39910, 443.63, 15);
    insert into guard.qvart4remove (hitag, SC, kol) values(39917, 24491.52, 170);
    insert into guard.qvart4remove (hitag, SC, kol) values(41991, 1341.82, 30);
    insert into guard.qvart4remove (hitag, SC, kol) values(53067, 3963.51, 31.824);
    insert into guard.qvart4remove (hitag, SC, kol) values(53269, 12978.35, 28.413);
    insert into guard.qvart4remove (hitag, SC, kol) values(53854, 2305.38, 19);
    insert into guard.qvart4remove (hitag, SC, kol) values(53871, 1035.66, 11);
    insert into guard.qvart4remove (hitag, SC, kol) values(54370, 329.44, 2);
    insert into guard.qvart4remove (hitag, SC, kol) values(95264, 1217.66, 2);
    insert into guard.qvart4remove (hitag, SC, kol) values(95272, 564.55, 1);
  
    UPDATE guard.qvart4remove SET flgweight=nm.flgweight FROM guard.qvart4remove q INNER JOIN nomen nm ON nm.hitag=q.hitag
    UPDATE guard.qvart4remove SET cost=sc/kol
  
    -- поиск последних возвратов
    CREATE TABLE #t(hitag int, BackNvId int);
    INSERT INTO #t(hitag, BackNvId)
      SELECT nv.hitag, MAX(nv.nvId) 
      FROM 
        nc 
        INNER JOIN nv ON nv.datnom=nc.DatNom
        INNER JOIN FirmsConfig fc ON fc.Our_id=nc.OurID
      WHERE 
        nc.sp<0 
        -- AND nc.nd>='01.01.2017' 
        AND (fc.FirmGroup=10 OR nc.OurID IN (19,20))
      GROUP BY nv.hitag;
  -- SELECT '#t' AS TabName,* FROM #t;
  
    UPDATE guard.qvart4remove SET BackNvId=#t.BackNvId FROM guard.qvart4remove g INNER JOIN #t ON #t.hitag=g.hitag;
  
    -- Где не получилось подобрать возвраты по Рестории, ищем возвраты по Морозко:
    TRUNCATE TABLE #t;
    INSERT INTO #t(hitag, BackNvId)
      SELECT nv.hitag, MAX(nv.nvId) 
      FROM 
        nc 
        INNER JOIN nv ON nv.datnom=nc.DatNom
        INNER JOIN FirmsConfig fc ON fc.Our_id=nc.OurID
      WHERE 
        nc.sp<0 
        -- AND nc.nd>='01.01.2017' 
        AND fc.FirmGroup=7
      GROUP BY nv.hitag;
  --  SELECT '#t' AS TabName,* FROM #t;
  
    UPDATE guard.qvart4remove SET BackNvId=#t.BackNvId 
    FROM guard.qvart4remove g INNER JOIN #t ON #t.hitag=g.hitag
    WHERE g.BackNvId IS NULL;
  
    UPDATE guard.qvart4remove SET Id=nv.tekid, BackDatnom=nv.Datnom 
    FROM 
      guard.qvart4remove g 
      INNER JOIN nv ON nv.nvid=g.BackNvId;
  
    -- Ищем исходные накладные (расходные),  к которым относятся найденные возвраты:
    UPDATE guard.qvart4remove
    SET SaleDatnom=nc.refdatnom
    FROM guard.qvart4remove g INNER JOIN nv ON nv.nvid=g.BackNvId INNER JOIN nc ON nc.datnom=nv.datnom
  
    -- Осталось еще 44 строки данных, для которых возврата найти не удалось.
    -- Постараемся найти хотя бы продажи.
  
  
    UPDATE guard.qvart4remove SET SaleNvId=NULL WHERE BackNvId IS NULL;
    UPDATE guard.qvart4remove SET SaleNvId=
      (SELECT TOP 1 nv.nvid 
       FROM 
         nv 
         INNER JOIN nc ON nc.datnom=nv.DatNom
         INNER JOIN firmsconfig fc ON fc.Our_id=nc.OurID
       WHERE 
         nv.hitag=guard.qvart4remove.hitag
         AND nv.datnom<1811150000
         AND nv.kol>0
         -- AND nc.Actn>0
         AND (fc.FirmGroup IN (7,10) OR nc.OurID IN (19,20))
       ORDER BY nv.datnom desc)
       where BackNvId IS null
  
    UPDATE guard.qvart4remove
      SET SaleDatnom=nv.datnom
      FROM guard.qvart4remove g INNER JOIN nv ON nv.nvid=g.SaleNvId WHERE SaleDatnom IS NULL;
    UPDATE guard.qvart4remove SET id=nv.tekid FROM guard.qvart4remove g INNER JOIN nv ON nv.nvid=g.salenvid WHERE id IS NULL;
  
    UPDATE guard.qvart4remove SET b_id=nc.b_id FROM guard.qvart4remove g INNER JOIN nc ON nc.datnom=g.SaleDatnom;
  
    -- генерирую случайные даты и номера для незаполненных возвратов:
    UPDATE guard.qvart4remove SET Backdatnom=dbo.fnDatNom(dbo.DatNomInDate(SaleDatnom)+5+10.0*RAND(), ROUND(1+1000.0*RAND(saledatnom),0))
      WHERE backnvid IS NULL;
  
  UPDATE guard.qvart4remove SET ncom=v.ncom, ncod=v.ncod FROM guard.qvart4remove g INNER JOIN visual v ON v.id=g.id;
  
  --  SELECT q.*, nm.name, def.gpname
  --  FROM 
  --    guard.qvart4remove q 
  --    INNER JOIN nomen nm ON nm.hitag=q.hitag
  --    LEFT JOIN def ON def.pin=q.b_id
  --  -- WHERE q.BackNvId IS NULL;

  END;

  select
    g.hitag, g.sc, g.kol, g.cost, g.backdatnom, g.ncom, g.ncod,
    ISNULL(bk.stfdate, dbo.DatnomInDate(g.backdatnom))  AS BackStfDate, 
    nc.ND AS SellStfDate, '' AS n_vet_svid,
    cm.doc_nom AS InpDocNom, cm.doc_date AS InpDocDate, v.our_id AS PostOurId,
    def.gpname AS buyer,
    v.dater, v.srokh, ROUND(g.cost*(1.2+0.2*RAND(g.id)),1) AS Price,
    g.id, v.startid, IIF(nm.flgweight=1, g.kol, 0) AS Weight, nm.flgWeight,
    bk.OurID, dbo.DatNomInDate(g.backdatnom) AS BackStfNom,
    dbo.DatNomInDate(g.SaleDatnom) AS SellStfNom,
    v.sert_id, g.SaleDatnom AS SellDatnom, 1 AS main, nm.netto,
    ve.fam AS VeFam, nm.name
  from
    guard.qvart4remove g
    INNER JOIN nomen nm ON nm.hitag=g.hitag
    LEFT JOIN nc BK ON BK.Datnom=g.backdatnom
    LEFT JOIN nc ON nc.datnom=g.SaleDatnom
    left JOIN visual v ON v.id=g.id
    -- LEFT JOIN sertif s ON s.sert_id=v.sert_id
    LEFT JOIN comman cm ON cm.ncom=g.ncom
    LEFT JOIN def ON def.pin=g.b_id
    -- LEFT JOIN nv ON nv.nvid=g.SaleNvId
    LEFT JOIN Vendors Ve ON Ve.Ncod=g.Ncod
END;