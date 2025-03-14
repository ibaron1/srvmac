USE ServiceMac
GO
DROP TABLE IF EXISTS Utilities.Launch_DataMartUpdate;

BEGIN

CREATE TABLE Utilities.Launch_DataMartUpdate
(LaunchDataMartUpdate INT NOT NULL, -- 1.set to 1 in ControlTower after populating source tables for datamart, reset to 0 in datamart after its update is completed
LaunchTime DATETIME NULL,			-- 2.timestamp after populating all source tables for datamart | reset to NULL when datamart Update is completed
PreviousLaunchTime DATETIME NULL,	-- 3.previous launch time
ErrorToLaunch VARCHAR(1000) NULL, 
ErrorTime DATETIME NULL,
);

INSERT Utilities.Launch_DataMartUpdate(LaunchDataMartUpdate)
VALUES(0);

END;

GO

DROP TRIGGER IF EXISTS Utilities.trg_del_Launch_DataMartUpdate
GO
CREATE TRIGGER Utilities.trg_del_Launch_DataMartUpdate
ON Utilities.Launch_DataMartUpdate
INSTEAD OF DELETE
AS
SET NOCOUNT ON;

SELECT 1;

GO

DROP TRIGGER IF EXISTS Utilities.trg_ins_Launch_DataMartUpdate
GO
CREATE TRIGGER Utilities.trg_ins_Launch_DataMartUpdate
ON Utilities.Launch_DataMartUpdate
INSTEAD OF INSERT
AS
SET NOCOUNT ON;

SELECT 1;

GO