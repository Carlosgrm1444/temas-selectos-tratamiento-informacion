use master;

create database romex_snapshot on
(
    name = RomexData,
    filename = 'C:\7BD\romexData_snapshot.ss'
),
(
    name = RomexParte1,
    filename = 'C:\7BD\romexParte1_snapshot.ss'
)
as snapshot of romex;