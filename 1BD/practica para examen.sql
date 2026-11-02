Create Database repaso_carlos
ON(
  Name = repaso_carlos1,
  Filename = 'C:\7BD\repaso_carlos.mdf',
  Size = 10MB,
  Filegrowth = 2MB
)
Log ON(
  Name = repaso_carlos2,
  Filename = 'C:\7BD\repaso_carlos.ndf'
)