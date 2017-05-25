/*
    数据库版本表，数据库更新会使用
*/

CREATE TABLE 'TB_Version' (
	'versionKey'    VARCHAR PRIMARY KEY, 			--版本标志
	'version'       INTEGER							--版本号
);
