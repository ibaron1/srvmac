use ServiceMac
go

CREATE OR ALTER PROCEDURE [Processing].[Update_CycleDateDifferencesForCalendarDate]
AS
TRUNCATE TABLE DateReference.CycleDateDifferencesForCalendarDate;

INSERT INTO DateReference.CycleDateDifferencesForCalendarDate
SELECT PivotTable.CalendarDate
, PivotTable.[-100] AS Minus100
, PivotTable.[-99] AS Minus99
, PivotTable.[-98] AS Minus98
, PivotTable.[-97] AS Minus97
, PivotTable.[-96] AS Minus96
, PivotTable.[-95] AS Minus95
, PivotTable.[-94] AS Minus94
, PivotTable.[-93] AS Minus93
, PivotTable.[-92] AS Minus92
, PivotTable.[-91] AS Minus91
, PivotTable.[-90] AS Minus90
, PivotTable.[-89] AS Minus89
, PivotTable.[-88] AS Minus88
, PivotTable.[-87] AS Minus87
, PivotTable.[-86] AS Minus86
, PivotTable.[-85] AS Minus85
, PivotTable.[-84] AS Minus84
, PivotTable.[-83] AS Minus83
, PivotTable.[-82] AS Minus82
, PivotTable.[-81] AS Minus81
, PivotTable.[-80] AS Minus80
, PivotTable.[-79] AS Minus79
, PivotTable.[-78] AS Minus78
, PivotTable.[-77] AS Minus77
, PivotTable.[-76] AS Minus76
, PivotTable.[-75] AS Minus75
, PivotTable.[-74] AS Minus74
, PivotTable.[-73] AS Minus73
, PivotTable.[-72] AS Minus72
, PivotTable.[-71] AS Minus71
, PivotTable.[-70] AS Minus70
, PivotTable.[-69] AS Minus69
, PivotTable.[-68] AS Minus68
, PivotTable.[-67] AS Minus67
, PivotTable.[-66] AS Minus66
, PivotTable.[-65] AS Minus65
, PivotTable.[-64] AS Minus64
, PivotTable.[-63] AS Minus63
, PivotTable.[-62] AS Minus62
, PivotTable.[-61] AS Minus61
, PivotTable.[-60] AS Minus60
, PivotTable.[-59] AS Minus59
, PivotTable.[-58] AS Minus58
, PivotTable.[-57] AS Minus57
, PivotTable.[-56] AS Minus56
, PivotTable.[-55] AS Minus55
, PivotTable.[-54] AS Minus54
, PivotTable.[-53] AS Minus53
, PivotTable.[-52] AS Minus52
, PivotTable.[-51] AS Minus51
, PivotTable.[-50] AS Minus50
, PivotTable.[-49] AS Minus49
, PivotTable.[-48] AS Minus48
, PivotTable.[-47] AS Minus47
, PivotTable.[-46] AS Minus46
, PivotTable.[-45] AS Minus45
, PivotTable.[-44] AS Minus44
, PivotTable.[-43] AS Minus43
, PivotTable.[-42] AS Minus42
, PivotTable.[-41] AS Minus41
, PivotTable.[-40] AS Minus40
, PivotTable.[-39] AS Minus39
, PivotTable.[-38] AS Minus38
, PivotTable.[-37] AS Minus37
, PivotTable.[-36] AS Minus36
, PivotTable.[-35] AS Minus35
, PivotTable.[-34] AS Minus34
, PivotTable.[-33] AS Minus33
, PivotTable.[-32] AS Minus32
, PivotTable.[-31] AS Minus31
, PivotTable.[-30] AS Minus30
, PivotTable.[-29] AS Minus29
, PivotTable.[-28] AS Minus28
, PivotTable.[-27] AS Minus27
, PivotTable.[-26] AS Minus26
, PivotTable.[-25] AS Minus25
, PivotTable.[-24] AS Minus24
, PivotTable.[-23] AS Minus23
, PivotTable.[-22] AS Minus22
, PivotTable.[-21] AS Minus21
, PivotTable.[-20] AS Minus20
, PivotTable.[-19] AS Minus19
, PivotTable.[-18] AS Minus18
, PivotTable.[-17] AS Minus17
, PivotTable.[-16] AS Minus16
, PivotTable.[-15] AS Minus15
, PivotTable.[-14] AS Minus14
, PivotTable.[-13] AS Minus13
, PivotTable.[-12] AS Minus12
, PivotTable.[-11] AS Minus11
, PivotTable.[-10] AS Minus10
, PivotTable.[-9] AS Minus9
, PivotTable.[-8] AS Minus8
, PivotTable.[-7] AS Minus7
, PivotTable.[-6] AS Minus6
, PivotTable.[-5] AS Minus5
, PivotTable.[-4] AS Minus4
, PivotTable.[-3] AS Minus3
, PivotTable.[-2] AS Minus2
, PivotTable.[-1] AS Minus1
, PivotTable.[0] AS Plus0
, PivotTable.[1] AS Plus1
, PivotTable.[2] AS Plus2
, PivotTable.[3] AS Plus3
, PivotTable.[4] AS Plus4
, PivotTable.[5] AS Plus5
, PivotTable.[6] AS Plus6
, PivotTable.[7] AS Plus7
, PivotTable.[8] AS Plus8
, PivotTable.[9] AS Plus9
, PivotTable.[10] AS Plus10
, PivotTable.[11] AS Plus11
, PivotTable.[12] AS Plus12
, PivotTable.[13] AS Plus13
, PivotTable.[14] AS Plus14
, PivotTable.[15] AS Plus15
, PivotTable.[16] AS Plus16
, PivotTable.[17] AS Plus17
, PivotTable.[18] AS Plus18
, PivotTable.[19] AS Plus19
, PivotTable.[20] AS Plus20
, PivotTable.[21] AS Plus21
, PivotTable.[22] AS Plus22
, PivotTable.[23] AS Plus23
, PivotTable.[24] AS Plus24
, PivotTable.[25] AS Plus25
, PivotTable.[26] AS Plus26
, PivotTable.[27] AS Plus27
, PivotTable.[28] AS Plus28
, PivotTable.[29] AS Plus29
, PivotTable.[30] AS Plus30
, PivotTable.[31] AS Plus31
, PivotTable.[32] AS Plus32
, PivotTable.[33] AS Plus33
, PivotTable.[34] AS Plus34
, PivotTable.[35] AS Plus35
, PivotTable.[36] AS Plus36
, PivotTable.[37] AS Plus37
, PivotTable.[38] AS Plus38
, PivotTable.[39] AS Plus39
, PivotTable.[40] AS Plus40
, PivotTable.[41] AS Plus41
, PivotTable.[42] AS Plus42
, PivotTable.[43] AS Plus43
, PivotTable.[44] AS Plus44
, PivotTable.[45] AS Plus45
, PivotTable.[46] AS Plus46
, PivotTable.[47] AS Plus47
, PivotTable.[48] AS Plus48
, PivotTable.[49] AS Plus49
, PivotTable.[50] AS Plus50
, PivotTable.[51] AS Plus51
, PivotTable.[52] AS Plus52
, PivotTable.[53] AS Plus53
, PivotTable.[54] AS Plus54
, PivotTable.[55] AS Plus55
, PivotTable.[56] AS Plus56
, PivotTable.[57] AS Plus57
, PivotTable.[58] AS Plus58
, PivotTable.[59] AS Plus59
, PivotTable.[60] AS Plus60
, PivotTable.[61] AS Plus61
, PivotTable.[62] AS Plus62
, PivotTable.[63] AS Plus63
, PivotTable.[64] AS Plus64
, PivotTable.[65] AS Plus65
, PivotTable.[66] AS Plus66
, PivotTable.[67] AS Plus67
, PivotTable.[68] AS Plus68
, PivotTable.[69] AS Plus69
, PivotTable.[70] AS Plus70
, PivotTable.[71] AS Plus71
, PivotTable.[72] AS Plus72
, PivotTable.[73] AS Plus73
, PivotTable.[74] AS Plus74
, PivotTable.[75] AS Plus75
, PivotTable.[76] AS Plus76
, PivotTable.[77] AS Plus77
, PivotTable.[78] AS Plus78
, PivotTable.[79] AS Plus79
, PivotTable.[80] AS Plus80
, PivotTable.[81] AS Plus81
, PivotTable.[82] AS Plus82
, PivotTable.[83] AS Plus83
, PivotTable.[84] AS Plus84
, PivotTable.[85] AS Plus85
, PivotTable.[86] AS Plus86
, PivotTable.[87] AS Plus87
, PivotTable.[88] AS Plus88
, PivotTable.[89] AS Plus89
, PivotTable.[90] AS Plus90
, PivotTable.[91] AS Plus91
, PivotTable.[92] AS Plus92
, PivotTable.[93] AS Plus93
, PivotTable.[94] AS Plus94
, PivotTable.[95] AS Plus95
, PivotTable.[96] AS Plus96
, PivotTable.[97] AS Plus97
, PivotTable.[98] AS Plus98
, PivotTable.[99] AS Plus99
, PivotTable.[100] AS Plus100
FROM
	(SELECT CalendarDate
	, CycleDifference
	, CycleDateForDifference
	FROM DateReference.CycleDateForCycleDifference AS CDFCD) AS SourceTable
PIVOT
(	MAX(CycleDateForDifference)
	FOR CycleDifference IN ([-100], [-99], [-98], [-97], [-96], [-95], [-94], [-93], [-92], [-91]
	, [-90], [-89], [-88], [-87], [-86], [-85], [-84], [-83], [-82], [-81]
	, [-80], [-79], [-78], [-77], [-76], [-75], [-74], [-73], [-72], [-71]
	, [-70], [-69], [-68], [-67], [-66], [-65], [-64], [-63], [-62], [-61]
	, [-60], [-59], [-58], [-57], [-56], [-55], [-54], [-53], [-52], [-51]
	, [-50], [-49], [-48], [-47], [-46], [-45], [-44], [-43], [-42], [-41]
	, [-40], [-39], [-38], [-37], [-36], [-35], [-34], [-33], [-32], [-31]
	, [-30], [-29], [-28], [-27], [-26], [-25], [-24], [-23], [-22], [-21]
	, [-20], [-19], [-18], [-17], [-16], [-15], [-14], [-13], [-12], [-11]
	, [-10], [-9], [-8], [-7], [-6], [-5], [-4], [-3], [-2], [-1], [0], [1]
	, [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14]
	, [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26]
	, [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38]
	, [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50]
	, [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62]
	,[63], [64], [65], [66], [67], [68], [69], [70], [71], [72], [73], [74]
	, [75], [76], [77], [78], [79], [80], [81], [82], [83], [84], [85], [86]
	, [87], [88], [89], [90], [91], [92], [93], [94], [95], [96], [97], [98]
	, [99], [100])) AS PivotTable;




