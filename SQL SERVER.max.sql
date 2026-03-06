
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Clinique_Plus_BD')
BEGIN
CREATE DATABASE Clinique_Plus_BD;
END

USE Clinique_Plus_BD;


CREATE SCHEMA Clinique;

--Creation de la table Specialite
CREATE TABLE Clinique.Specialites(
ID_Specialites INT PRIMARY KEY IDENTITY(1,1),
Nom VARCHAR(50) NOT NULL,
Tarif_Consultation DECIMAL(6,2) CHECK(Tarif_Consultation>0) DEFAULT 0,
);

--Creation de la table Medecin
CREATE TABLE Clinique.Medecins(
ID_Medecins INT PRIMARY KEY IDENTITY(1,1),
Matricule VARCHAR(10) NOT NULL,
Nom VARCHAR(8) NOT NULL,
Prenom NVARCHAR(50) NOT NULL,
Telephone VARCHAR(50) NOT NULL,
Email VARCHAR(50) CHECK(Email like '%@%.%') NOT NULL UNIQUE,
Date_Embauche DATE DEFAULT GETDATE (),
Salaire DECIMAL (6,2) CHECK(Salaire>0) NOT NULL DEFAULT 0,
Adresse NVARCHAR(50) NOT NULL,
ID_Specialites INT,
CONSTRAINT FK_Medecin_Specialites
FOREIGN KEY (ID_Specialites ) 
REFERENCES Clinique.Specialites (ID_Specialites) 
ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT uk_matricule UNIQUE (Matricule),
CONSTRAINT chk_Matricule 
CHECK (Matricule LIKE 'MED-[0-9]')
);

--Creation de la table patient
CREATE TABLE Clinique.patient(
ID_Patient INT PRIMARY KEY IDENTITY(1,1),
Numeros VARCHAR(20) CHECK(Numeros LIKE'PAT-[1-2][0-9][1-2][1-7]-[0-9][0-9][0-9][0-9]'),
Nom  VARCHAR(50) NOT NULL,
Prenom  NVARCHAR(50) NOT NULL,
Date_Naissance  DATE NOT NULL,
Age  AS DATEDIFF(YEAR,Date_Naissance,GETDATE()),
Sexe  VARCHAR(50) CHECK(Sexe in('M','F')) NOT NULL,
Groupe_Sanguin VARCHAR(3) NULL,
Telephone  VARCHAR(50) NOT NULL,
Email  VARCHAR(50) CHECK(Email like '%@%.%') NOT NULL UNIQUE,
Adresse NVARCHAR(50) NOT NULL,
Date_Inscription  AS  GETDATE ());

--Creation de la table Medicament
CREATE TABLE Clinique.Medicament(
ID_Medicament INT PRIMARY KEY IDENTITY(1,1),
Nom_Commercial VARCHAR(50) NOT NULL,
DCI VARCHAR(50) NOT NULL,
Categorie VARCHAR(50) CHECK(Categorie in('Antalgique','AINS','Sedatif','Antibiotique','Antihypertenseur')),
Prix_Unitaire DECIMAL(3,2) CHECK(Prix_Unitaire >0) NOT NULL,
Stock INT NOT NULL DEFAULT 0
);

--Creation de la table Consultation
CREATE TABLE Clinique.Consultation(
ID_Consultation  INT PRIMARY KEY IDENTITY(1,1),
ID_Patient INT,
ID_Medecins INT,
Date_Consultation date DEFAULT getdate(),
Motif VARCHAR(50) NOT NULL,
Diagnostic TEXT NOT NULL,
Statut VARCHAR(50) CHECK(Statut in('en attente','en cours','terminer')) NOT NULL,
CONSTRAINT FK_Cosultation_Patient
FOREIGN KEY (ID_Patient) REFERENCES Clinique.Patient(ID_Patient) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT FK_Cosultation_Medecins
FOREIGN KEY (ID_Medecins) REFERENCES Clinique.Medecins(ID_Medecins) ON DELETE CASCADE ON UPDATE CASCADE,
);

--Creation de la table Prescription
CREATE TABLE Clinique.Prescription(
ID_Prescrition INT PRIMARY KEY IDENTITY(1,1),
ID_Consultation INT,
ID_Medicament   INT,
Posologie VARCHAR(50) NOT NULL,
Duree_Jour INT NOT NULL
CONSTRAINT FK_Prescription_Consultation
FOREIGN KEY (ID_Consultation) REFERENCES Clinique.Consultation (ID_Consultation)
ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT FK_Prescription_Medicament
FOREIGN KEY (ID_Medicament) REFERENCES Clinique.Medicament (ID_Medicament) 
ON DELETE CASCADE ON UPDATE CASCADE,
Qte int NOT NULL
);

--Creation de la table Facture
CREATE TABLE Clinique.Facture(
ID_Facture INT PRIMARY KEY IDENTITY(1,1),
ID_Consultation INT,
Montant_Brut DECIMAL(10,2) CHECK(Montant_Brut>0)  NOT NULL,
Remis DECIMAL(5,2) CHECK(Remis between 0 and 100) DEFAULT 0 NOT NULL,
Montant_Net  as(Montant_Brut*(1-Remis/100)) PERSISTED,
Statut VARCHAR(50) DEFAULT'en attente' CHECK(Statut in('paye','impaye','en attente')),
CONSTRAINT FK_Facture_Consultion
FOREIGN KEY (ID_Consultation) REFERENCES Clinique.Consultation (ID_Consultation)
ON DELETE CASCADE ON UPDATE CASCADE
);
drop table Clinique.Facture;
--Creation d'index
CREATE NONCLUSTERED INDEX I_Medecin_nom ON Clinique.Medecins(Nom);
CREATE NONCLUSTERED INDEX I_Patient_nom_Prenom ON Clinique.patient(Nom,Prenom);
CREATE NONCLUSTERED INDEX I_Facture_ID ON Clinique.Facture(ID_Facture); 

--Insertion
INSERT INTO Clinique.Specialites (Nom, Tarif_Consultation) VALUES
('Cardiologie', 65.00),
('Dermatologie', 55.00),
('Pédiatrie', 50.00),
('Gynécologie', 60.00),
('Ophtalmologie', 58.50),
('Médecine générale', 30.00);

INSERT INTO Clinique.Medecins (Matricule, Nom, Prenom, Telephone, Email, Date_Embauche, Salaire, Adresse, ID_Specialites) VALUES
('MED-1', 'Dupont', 'Jean', '0123456789', 'jean.dupont@clinique.fr', '2020-03-15', 4500.00, '15 Rue de la Paix, 75001 Paris', 1),
('MED-2', 'Martin', 'Sophie', '0145678923', 'sophie.martin@clinique.fr', '2019-06-10', 5200.00, '8 Avenue Victor Hugo, 69002 Lyon', 2),
('MED-3', 'Bernard', 'Pierre', '0321456987', 'pierre.bernard@clinique.fr', '2021-01-20', 3800.00, '25 Boulevard Gambetta, 59000 Lille', 3),
('MED-4', 'Petit', 'Claire', '0456789123', 'claire.petit@clinique.fr', '2018-11-05', 6000.00, '42 Rue Paradis, 13001 Marseille', 4),
('MED-5', 'Moreau', 'Thomas', '0567891234', 'thomas.moreau@clinique.fr', '2022-02-28', 4100.00, '7 Place du Capitole, 31000 Toulouse', 5),
('MED-6', 'Dubois', 'Isabelle', '0678912345', 'isabelle.dubois@clinique.fr', '2020-09-12', 4800.00, '18 Quai des Belges, 34000 Montpellier', 1),
('MED-7', 'Laurent', 'Nicolas', '0789123456', 'nicolas.laurent@clinique.fr', '2021-07-19', 3500.00, '33 Rue Sainte-Catherine, 33000 Bordeaux', 2),
('MED-8', 'Leroy', 'Emilie', '0891234567', 'emilie.leroy@clinique.fr', '2023-04-03', 3200.00, '12 Grand Rue, 67000 Strasbourg', 3);

INSERT INTO Clinique.Patient (Numeros, Nom, Prenom, Date_Naissance, Sexe, Groupe_Sanguin, Telephone, Email, Adresse) VALUES
('PAT-2022-0101', 'Dupont', 'Jean', '1985-03-15', 'M', 'A+', '0612345678', 'jean.dupont@email.com', '15 rue de la Paix, 75001 Paris'),
('PAT-2022-0102', 'Martin', 'Sophie', '1990-07-22', 'F', 'O-', '0623456789', 'sophie.martin@email.com', '8 avenue Victor Hugo, 69002 Lyon'),
('PAT-2023-0050', 'Bernard', 'Michel', '1978-11-05', 'M', 'B+', '0634567890', 'michel.bernard@email.com', '25 boulevard Haussmann, 13001 Marseille'),
('PAT-2023-0051', 'Petit', 'Marie', '1982-09-18', 'F', 'AB+', '0645678901', 'marie.petit@email.com', '42 rue Nationale, 59000 Lille'),
('PAT-2023-0052', 'Robert', 'Pierre', '1995-02-28', 'M', 'A-', '0656789012', 'pierre.robert@email.com', '7 place du Capitole, 31000 Toulouse'),
('PAT-2024-0001', 'Richard', 'Isabelle', '1988-12-10', 'F', 'O+', '0667890123', 'isabelle.richard@email.com', '33 cours Mirabeau, 13100 Aix-en-Provence'),
('PAT-2024-0002', 'Durand', 'Thomas', '1975-06-30', 'M', 'B-', '0678901234', 'thomas.durand@email.com', '12 quai des Belges, 34000 Montpellier'),
('PAT-2024-0003', 'Moreau', 'Julie', '1992-04-25', 'F', 'A+', '0689012345', 'julie.moreau@email.com', '5 rue Saint-Michel, 44000 Nantes'),
('PAT-2024-0004', 'Simon', 'Nicolas', '1980-08-14', 'M', 'AB-', '0690123456', 'nicolas.simon@email.com', '18 Grand Rue, 67000 Strasbourg'),
('PAT-2024-0005', 'Laurent', 'Céline', '1987-01-07', 'F', 'O+', '0611223344', 'celine.laurent@email.com', '27 rue de la République, 69003 Lyon'),
('PAT-2024-0006', 'Lefebvre', 'David', '1972-10-19', 'M', 'A+', '0622334455', 'david.lefebvre@email.com', '9 avenue Jean Médecin, 06000 Nice'),
('PAT-2024-0007', 'Michel', 'Emilie', '1998-05-03', 'F', 'B+', '0633445566', 'emilie.michel@email.com', '55 rue Gambetta, 33000 Bordeaux'),
('PAT-2025-0001', 'Garcia', 'Antoine', '1983-12-21', 'M', 'O-', '0644556677', 'antoine.garcia@email.com', '22 place Stanislas, 54000 Nancy'),
('PAT-2025-0002', 'David', 'Laura', '1991-09-09', 'F', 'A-', '0655667788', 'laura.david@email.com', '4 rue de la Barre, 76000 Rouen'),
('PAT-2025-0003', 'Bertrand', 'François', '1977-03-27', 'M', 'AB+', '0666778899', 'francois.bertrand@email.com', '16 boulevard de Strasbourg, 31000 Toulouse');


INSERT INTO Clinique.Consultation (ID_Patient, ID_Medecins, Date_Consultation, Motif, Diagnostic, Statut) VALUES
( NULL,3, '2026-01-05 09:30:00', 'Fièvre et maux de tête', 'Grippe saisonnière', 'terminer'),
(2, 1, '2026-01-06 10:15:00', 'Douleurs abdominales', 'Gastro-entérite', 'en attente'),
(NULL, 5, '2026-01-07 14:00:00', 'Toux persistante', 'Bronchite aiguë', 'en attente'),
(4, 2, '2026-01-08 11:30:00', 'Douleur au genou', 'Entorse légère', 'terminer'),
(5, 4, '2026-01-09 15:45:00', 'Éruption cutanée', 'Eczéma de contact', 'en cours'),
(6, 7, '2026-01-10 09:00:00', 'Vertiges et fatigue', 'Hypotension artérielle', 'terminer'),
(7, 6, '2026-01-12 16:30:00', 'Douleur thoracique', 'Examen normal, stress', 'en cours'),
(8, 8, '2026-01-13 08:45:00', 'Mal de gorge', 'Angine rouge', 'terminer'),
(9, 3, '2026-01-14 13:15:00', 'Suivi grossesse', 'Grossesse normale, 2e trimestre', 'terminer'),
(10, 2, '2026-01-15 10:30:00', 'Lombalgie', 'Lumbago', 'en attente'),
(11, 1, '2026-01-16 09:45:00', 'Tension artérielle élevée', 'Hypertension légère', 'terminer'),
(12, 4, '2026-01-17 14:30:00', 'Problème de vision', 'Presbytie', 'terminer'),
(13, 5, '2026-01-18 11:00:00', 'Allergie saisonnière', 'Rhinite allergique', 'terminer'),
(14, 7, '2026-01-19 15:15:00', 'Insomnie', 'Trouble anxieux', 'terminer'),
(15, 6, '2026-01-20 08:30:00', 'Douleur épaule', 'Tendinite', 'terminer'),
(1, 8, '2026-01-22 16:00:00', 'Suivi grippe', 'Guérison complète', 'terminer'),
(3, 2, '2026-01-23 10:45:00', 'Renouvellement ordonnance', 'Traitement à reconduire', 'terminer'),
(5, 4, '2026-01-24 09:15:00', 'Piqûre de tique', 'Morsure sans infection', 'terminer'),
(8, 1, '2026-01-25 14:45:00', 'Fièvre enfant', 'Otite moyenne', 'en attente'),
(12, 3, '2026-01-26 11:30:00', 'Douleur dentaire', 'Carie à traiter', 'en cours');

INSERT INTO Clinique.Medicament (Nom_Commercial, DCI, Categorie, Prix_Unitaire, Stock) VALUES
('Doliprane', 'Paracétamol', 'Antalgique', 2.50, 150),
('Ibuprofène EG', 'Ibuprofène', 'Antihypertenseur', 3.20, 80),
('Amoxicilline Mylan', 'Amoxicilline', 'Antibiotique', 5.75, 45),
('Spasfon', 'Phloroglucinol', 'AINS', 4.30, 60),
('Ventoline', 'Salbutamol', 'Sedatif', 6.90, 25),
('Levothyrox', 'Lévothyroxine', 'Antihypertenseur', 8.40, 30),
('Xanax', 'Alprazolam', 'Sedatif', 4.80, 40),
('Piqûre de rappel', 'Cyanocobalamine', 'Antihypertenseur', 7.25, 15),
('Dexeryl', 'Dexpanthénol', 'Sedatif', 5.90, 55),
('Efferalgan', 'Paracétamol', 'Antalgique', 3.10, 120);

INSERT INTO Clinique.Prescription (ID_Consultation, ID_Medicament, Posologie, Duree_Jour,Qte) VALUES
(1, 5, '1 comprimé matin et soir', 7,1),
(2, 12, '2 comprimés le matin', 10,3),
(3, 3, '1 ampoule par jour', 5,5),
(4, 8, '1 sachet 3 fois par jour', 5,6),
(5, 15, '2 comprimés le soir', 30,10),
(6, 7, '1 comprimé matin, midi et soir', 10,4),
(7, 10, '1 cuillère à soupe après chaque repas', 15,4),
(8, 2, '1 comprimé par jour', 90,5),
(9, 14, '2 pulvérisations dans chaque narine', 20,6),
(10, 6, '1 comprimé matin et soir', 14,5),
(11, 9, '1 sachet le matin à jeun', 30,5),
(12, 4, '1 comprimé 2 fois par jour', 8,9),
(13, 11, '1 injection sous-cutanée par semaine', 28,2),
(14, 13, '1 comprimé au coucher', 15,5),
(15, 1, '2 comprimés 3 fois par jour', 7,3);

INSERT INTO Clinique.Facture (ID_Consultation, Montant_Brut, Remis, Statut) VALUES
(1, 120.00, 0, 'paye'),
(2, 250.50, 10, 'impaye'),
(3, 80.00, 0, 'en attente'),
(4, 450.00, 15,  'paye'),
(5, 175.25, 5,  'impaye'),
(6, 320.00, 20,  'paye'),
(7, 95.90, 0,  'paye'),
(8, 520.00, 25,  'en attente'),
(9, 210.00, 0, 'paye'),
(10, 380.50, 30,  'impaye'),
(11, 145.00, 10,  'paye'),
(12, 620.00, 15,  'impaye');
select * from Clinique.Consultation;
--Creation de vue
CREATE VIEW  V_Info_Complet_patient AS (
 SELECT Cp.Nom
 + ' '+ Cp.Prenom AS Nom_complet,
 Cm.Nom AS Nom_Medecin,
 Cs.Nom As Specialite,
 Cc.Date_Consultation,
 Cc.Motif,Cc.Statut
 FROM Clinique.patient AS Cp 
 INNER JOIN Clinique.Consultation AS Cc ON Cc.ID_Patient=Cp.ID_Patient
 INNER JOIN Clinique.Medecins AS Cm ON Cc.ID_Medecins=Cm.ID_Medecins
 INNER JOIN Clinique.Specialites AS Cs ON Cm.ID_Specialites=Cs.ID_Specialites);
 select * from V_Factures_Impayees;
 CREATE VIEW V_Factures_Impayees AS (
 SELECT Cp.Nom AS Nom_Patient,
 Cp.Telephone AS Telephone,
 Cf.montant_Net AS Montant_du,
 Cc.Date_Consultation
 FROM Clinique.patient AS Cp
 INNER JOIN Clinique.Consultation AS Cc ON Cp.ID_patient = Cc.ID_Patient
 INNER JOIN Clinique.Facture AS Cf ON Cf.ID_Consultation = Cc.ID_Consultation
  WHERE Cf.Statut='impaye'
);
 select Statut from Clinique.Facture;
 drop view V_Factures_Impayees;
 --Ajout de colonnes
 ALTER TABLE Clinique.Consultation 
 ADD Note_interne TEXT ;
 drop view V_Factures_Impayees;
ALTER TABLE Clinique.Medecins
ADD Specialisation_complementaire VARCHAR(50) NULL;

ALTER TABLE Clinique.patient 
ADD Derniere_Maj DATETIME
DEFAULT CURRENT_TIMESTAMP;

--Modification de colonne
ALTER TABLE Clinique.patient 
ALTER COLUMN Adresse VARCHAR(100) NOT NULL;

--Ajout de containte
ALTER TABLE Clinique.patient 
ADD CONSTRAINT CK_Date_Naissance 
CHECK (Date_Naissance<CAST(GETDATE() AS DATE));

--Supression de colonne
ALTER  TABLE Clinique.patient
DROP COLUMN Groupe_Sanguin; 

--Creation d'une nouvelle table(Clinique.Audit_Connexion)
CREATE TABLE Clinique.Audit_Connexion(
ID_Audite  INT IDENTITY(1,1) PRIMARY KEY,
Utilisateur VARCHAR(50) NOT NULL,
Date_Action DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
Type_Action VARCHAR(50)NOT NULL,
Table_cible VARCHAR(50) NULL ,
CONSTRAINT CK_Type_Action CHECK(Type_Action IN ('connexion','deconnexion','modification')));

--Selection
SELECT 
Cm.Matricule AS Matricule_Medecin,
Cm.Nom + ' ' +Cm.Prenom AS Nom_Compplet,
Cm.Email,
Cs.Nom AS Specialite
FROM Clinique.Medecins AS Cm
INNER JOIN Clinique.Specialites AS Cs ON Cs.ID_Specialites=Cm.ID_Specialites
ORDER BY Cs.Nom,Cm.Nom;
SELECT
Cp.ID_Patient AS Numero,
Cp.Nom+' '+Cp.Prenom AS Nom_Complet,
Cp.Date_Naissance,
 DATEDIFF(YEAR,Cp.Date_Naissance,GETDATE()) AS Age
FROM Clinique.patient AS Cp                                                                 
WHERE YEAR(Date_Naissance)>1990
ORDER BY Age ASC;
SELECT
 ID_Consultation,
 Motif,
 FORMAT (Date_Consultation,'dd/mm/yyyy') AS DATES
 FROM Clinique.Consultation
 WHERE YEAR(Date_Consultation)=2026 AND Statut='terminer'
 ORDER BY Date_Consultation DESC;
SELECT TOP 5 WITH TIES
Nom_Commercial,
Categorie,
Prix_Unitaire
FROM Clinique.Medicament
ORDER BY Prix_Unitaire DESC;
--agregation
SELECT
Cm.Nom,+' '+Cm.Prenom AS Nom_Complet,
Cs.Nom AS Specialite,
COUNT(Cc.ID_Consultation) AS NbreConsultation,
SUM (CASE WHEN Statut='terminer' THEN 1 
ELSE 0
END) AS ConsultationTermine
FROM Clinique.Medecins AS Cm
INNER JOIN Clinique.Specialites AS Cs ON Cs.ID_Specialites=Cm.ID_Specialites
INNER JOIN Clinique.Consultation AS Cc ON Cc.ID_Medecins=Cm.ID_Medecins
GROUP BY Cm.Nom,Cm.Prenom,Cs.Nom
ORDER BY NbreConsultation;
 --4.6 chiffre d'affaire par medecin 
SELECT
Cs.Nom AS libele,
COUNT( Cf.Statut) AS Facture_Paye,
ROUND(SUM(Cf.Montant_Net),2) AS Chiffre_Affaire
FROM Clinique.Specialites AS Cs
INNER JOIN Clinique.Medecins AS Cm ON Cs.ID_Specialites=Cm.ID_Specialites
INNER JOIN Clinique.Consultation AS Cc ON Cc.ID_Medecins=Cm.ID_Medecins
INNER JOIN Clinique.Facture AS Cf ON Cf.ID_Consultation=Cc.ID_Consultation
GROUP BY Cs.Nom
HAVING ROUND(SUM(Cf.Montant_Net),2)>400;

--4.7
SELECT
Cp.Sexe,
COUNT(*) AS Nbre_Patient,
ROUND(AVG(CAST(DATEDIFF(YEAR,Cp.Date_Naissance,GETDATE()) AS FLOAT)),1) AS Moyenne_Age,
MAX(Cp.Date_Naissance) AS Moins_Age,
MIN(Cp.Date_Naissance) AS Plus_Age
FROM Clinique.patient AS Cp 
GROUP BY Cp.Sexe;
--4.8
SELECT
Cm.Nom_Commercial , 
Cm.Categorie,
COALESCE(Stock,0) AS Stock,
CASE WHEN COALESCE(Stock,0)<20 THEN 'Critique'
ELSE 'Faible' END AS Niveau_Alerte
FROM Clinique.Medicament AS Cm
WHERE COALESCE(Stock,0) <=50
ORDER BY COALESCE(Stock,0) DESC;
--4.9
SELECT
FORMAT(Date_Consultation,'%y-%m')AS Mois_formate,
COUNT(*) AS Total_Consultation,
SUM(CASE WHEN Statut='terminer'THEN 1 ELSE 0 END)
AS Consultation_Terminer,
ROUND(SUM(CASE WHEN Statut='terminer'THEN 1 ELSE 0 END)/COUNT(*),1)
AS Taux_Realisation
FROM Clinique.Consultation
GROUP BY FORMAT(Date_Consultation,'%y-%m'),ID_Consultation;
--5.1
SELECT
Cc.Date_Consultation,
Cp.Nom+' '+Cp.Prenom AS Nom_Complet_P,
Cm.Nom+' '+Cm.Prenom AS Nom_Complet_M,
Cme.Nom_Commercial AS Nom,
Cpr.Posologie,
Cpr.Duree_Jour,
Cpr.Qte
FROM Clinique.Consultation AS Cc
INNER JOIN Clinique.patient AS Cp ON Cp.ID_Patient=Cc.ID_Patient
INNER JOIN Clinique.Medecins AS Cm ON Cm.ID_Medecins=Cc.ID_Medecins
INNER JOIN Clinique.Prescription AS Cpr ON Cpr.ID_Consultation=Cc.ID_Consultation
INNER JOIN Clinique.Medicament AS Cme ON Cme.ID_Medicament=Cpr.ID_Medicament
ORDER BY Cc.Date_Consultation
;
--5.2
SELECT
F.ID_Facture,
C.Date_Consultation AS DateFacturation,
p.Nom AS NomPatient,
m.Nom AS NomMedecin,F.Montant_Brut AS MontantDeBase,
F.Remis,ROUND(F.Montant_Net,2) AS Montant_Net

FROM Clinique.Facture AS F
INNER JOIN Clinique.Consultation AS C ON C.ID_Consultation=F.ID_Consultation
INNER JOIN Clinique.Medecins AS m ON m.ID_Medecins=C.ID_Medecins
INNER JOIN Clinique.patient AS p ON p.ID_Patient=C.ID_Patient
WHERE F.Statut ='paye'
ORDER BY C.Date_Consultation
;
--5.3
SELECT
c.ID_Consultation AS NumeroDosier,
p.Nom+' '+p.Prenom AS NonComplet,
p.Date_Inscription
FROM Clinique.Consultation AS c 
LEFT JOIN Clinique.patient AS p ON p.ID_Patient=c.ID_Patient
WHERE c.ID_Patient IS NULL;


select*from Clinique.Consultation;




SELECT * FROM Clinique.Medicament;
SELECT * FROM Clinique.Audit_Connexion;

 SELECT * from V_Info_Complet_patient;

