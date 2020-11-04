local SPELLS = {
{ 61999, 1 },
{ 20484, 1 },
{ 20707, 1 },
{ 320341, 2 },
{ 212084, 2 },
{ 204021, 2 },
{ 187827, 2 },
{ 263648, 2 },
{ 185245, 2 },
{ 194844, 2 },
{ 49028, 2 },
{ 56222, 2 },
{ 219809, 2 },
{ 55233, 2 },
{ 50334, 2 },
{ 6795, 2 },
{ 102558, 2 },
{ 204066, 2 },
{ 80313, 2 },
{ 115399, 2 },
{ 322507, 2 },
{ 325153, 2 },
{ 132578, 2 },
{ 115546, 2 },
{ 115176, 2 },
{ 31850, 2 },
{ 86659, 2 },
{ 105809, 2 },
{ 1161, 2 },
{ 1160, 2 },
{ 12975, 2 },
{ 871, 2 },
{ 355, 2 },
{ 258925, 3 },
{ 191427, 3 },
{ 275699, 3 },
{ 42650, 3 },
{ 152279, 3 },
{ 63560, 3 },
{ 279302, 3 },
{ 51271, 3 },
{ 49206, 3 },
{ 207289, 3 },
{ 115989, 3 },
{ 106951, 3 },
{ 194223, 3 },
{ 202770, 3 },
{ 319454, 3 },
{ 102560, 3 },
{ 102543, 3 },
{ 193530, 3 },
{ 19574, 3 },
{ 321530, 3 },
{ 266779, 3 },
{ 260402, 3 },
{ 201430, 3 },
{ 288613, 3 },
{ 12042, 3 },
{ 190319, 3 },
{ 84714, 3 },
{ 12472, 3 },
{ 55342, 3 },
{ 321507, 3 },
{ 113656, 3 },
{ 123904, 3 },
{ 152173, 3 },
{ 137639, 3 },
{ 322109, 3 },
{ 31884, 3 },
{ 231895, 3 },
{ 343721, 3 },
{ 105809, 3 },
{ 10060, 3 },
{ 319952, 3 },
{ 228260, 3 },
{ 13750, 3 },
{ 13877, 3 },
{ 271877, 3 },
{ 343142, 3 },
{ 51690, 3 },
{ 121471, 3 },
{ 277925, 3 },
{ 79140, 3 },
--{ Ascendance, 3 },
{ 51533, 3 },
{ 198067, 3 },
{ 192249, 3 },
{ 191634, 3 },
{ 152108, 3 },
{ 113858, 3 },
{ 113860, 3 },
{ 111898, 3 },
{ 267217, 3 },
{ 205180, 3 },
{ 265187, 3 },
{ 1122, 3 },
{ 107574, 3 },
--{ Bladestorm, 3 },
{ 262228, 3 },
{ 228920, 3 },
{ 152277, 3 },
{ 1719, 3 },
{ 280772, 3 },
{ 278326, 4 },
{ 2782, 4 },
{ 88423, 4 },
{ 2908, 4 },
{ 19801, 4 },
{ 475, 4 },
--{ ArcaneTorrent, 4 },
{ 265221, 4 },
{ 20594, 4 },
{ 4987, 4 },
{ 213644, 4 },
{ 32375, 4 },
{ 527, 4 },
{ 213634, 4 },
{ 51886, 4 },
{ 77130, 4 },
{ 8143, 4 },
{ 179057, 5 },
{ 109248, 5 },
{ 119381, 5 },
{ 255654, 5 },
{ 20549, 5 },
{ 205369, 5 },
{ 192058, 5 },
{ 30283, 5 },
{ 46968, 5 },
{ 196718, 6 },
{ 51052, 6 },
{ 31821, 6 },
{ 62618, 6 },
{ 97462, 6 },
{ 202138, 7 },
{ 207684, 7 },
{ 202137, 7 },
{ 207167, 7 },
{ 108199, 7 },
{ 99, 7 },
{ 102359, 7 },
{ 132469, 7 },
{ 102793, 7 },
{ 162488, 7 },
{ 31661, 7 },
{ 113724, 7 },
{ 324312, 7 },
{ 116844, 7 },
{ 198898, 7 },
{ 115750, 7 },
{ 8122, 7 },
{ 204263, 7 },
{ 51485, 7 },
{ 5484, 7 },
{ 5246, 7 },
{ 102351, 8 },
{ 197721, 8 },
{ 319454, 8 },
{ 33891, 8 },
{ 203651, 8 },
{ 740, 8 },
{ 325197, 8 },
{ 322118, 8 },
{ 115310, 8 },
{ 216331, 8 },
{ 31884, 8 },
{ 200025, 8 },
{ 105809, 8 },
{ 200183, 8 },
{ 64843, 8 },
{ 246287, 8 },
{ 265202, 8 },
{ 10060, 8 },
{ 47536, 8 },
{ 109964, 8 },
{ 15286, 8 },
{ 108281, 8 },
{ 114052, 8 },
{ 198838, 8 },
{ 108280, 8 },
{ 188501, 9 },
{ 205636, 9 },
{ 29166, 9 },
{ 132158, 9 },
{ 106898, 9 },
{ 186257, 9 },
{ 199483, 9 },
{ 5384, 9 },
{ 34477, 9 },
{ 235219, 9 },
{ 110959, 9 },
{ 66, 9 },
{ 205025, 9 },
{ 116841, 9 },
{ 58984, 9 },
{ 73325, 9 },
{ 64901, 9 },
{ 1725, 9 },
{ 114018, 9 },
{ 57934, 9 },
{ 1856, 9 },
{ 198103, 9 },
{ 16191, 9 },
{ 20608, 9 },
{ 79206, 9 },
{ 192077, 9 },
{ 333889, 9 },
{ 64382, 9 },
{ 102342, 10 },
{ 116849, 10 },
{ 1022, 10 },
{ 6940, 10 },
{ 204018, 10 },
{ 633, 10 },
{ 47788, 10 },
{ 33206, 10 },
{ 207399, 10 },
{ 3411, 10 },
{ 196555, 11 },
{ 186265, 11 },
{ 45438, 11 },
{ 642, 11 },
{ 31224, 11 },
{ 198589, 12 },
{ 48707, 12 },
{ 48743, 12 },
{ 48792, 12 },
{ 49039, 12 },
{ 327574, 12 },
{ 22812, 12 },
{ 319454, 12 },
{ 108238, 12 },
{ 61336, 12 },
{ 109304, 12 },
{ 108978, 12 },
{ 342245, 12 },
{ 235313, 12 },
{ 11426, 12 },
{ 235450, 12 },
{ 122278, 12 },
{ 122783, 12 },
{ 243435, 12 },
{ 115203, 12 },
{ 122470, 12 },
{ 498, 12 },
{ 205191, 12 },
{ 184662, 12 },
{ 19236, 12 },
{ 47585, 12 },
{ 185311, 12 },
--{ Evasion/Riposte, 12 },
{ 108271, 12 },
{ 108416, 12 },
{ 104773, 12 },
{ 118038, 12 },
{ 184364, 12 },
{ 23920, 12 },
{ 211881, 13 },
--{ Asphyxiate, 13 },
{ 22570, 13 },
{ 5211, 13 },
{ 19577, 13 },
{ 287712, 13 },
{ 853, 13 },
{ 88625, 13 },
{ 64044, 13 },
{ 408, 13 },
{ 6789, 13 },
{ 107570, 13 },
{ 217832, 14 },
{ 186387, 14 },
{ 187650, 14 },
{ 115078, 14 },
{ 107079, 14 },
{ 20066, 14 },
{ 88625, 14 },
{ 2094, 14 },
{ 51514, 14 },
{ 183752, 15 },
{ 47528, 15 },
{ 106839, 15 },
{ 78675, 15 },
{ 147362, 15 },
{ 187707, 15 },
{ 2139, 15 },
{ 116705, 15 },
{ 31935, 15 },
{ 96231, 15 },
{ 15487, 15 },
{ 1766, 15 },
{ 57994, 15 },
{ 89766, 15 },
{ 19647, 15 },
{ 6552, 15 },
}