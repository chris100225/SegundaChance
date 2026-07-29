CREATE DATABASE ReHope;
GO

USE ReHope;
GO

---------- TABELAS ----------
CREATE TABLE TipoProduto (
	TipoProdutoID	INT PRIMARY KEY IDENTITY,
	NomeTipo		VARCHAR(100) UNIQUE NOT NULL
); 
GO

CREATE TABLE Localizacao (
	LocalizacaoID	INT PRIMARY KEY IDENTITY,
	NomeLocalizacao	VARCHAR(100) UNIQUE NOT NULL
);
GO

CREATE TABLE Usuario (
	UsuarioID	UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
	Nome		NVARCHAR(100) NOT NULL,
	Email		NVARCHAR(200) UNIQUE NOT NULL,
	Senha		VARBINARY(32) NOT NULL,
	Telefone	VARCHAR(15) UNIQUE NOT NULL,
	StatusUsuario BIT DEFAULT 1 
);
GO

CREATE TABLE Categoria(
	CategoriaID		INT PRIMARY KEY IDENTITY,
	NomeCategoria	VARCHAR(100) UNIQUE NOT NULL,
	TipoProdutoID	INT NOT NULL,

	CONSTRAINT FK_Categoria_TipoProduto
		FOREIGN KEY (TipoProdutoID) REFERENCES TipoProduto(TipoProdutoID)
);
GO

CREATE TABLE Produto (
	ProdutoID		UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
	NomeProduto		NVARCHAR(100) NOT NULL,
	Preco			DECIMAL(10,2) NOT NULL,
	Descricao		NVARCHAR(MAX) NOT NULL,
	Codigo			INT IDENTITY UNIQUE NOT NULL,
	Tamanho			VARCHAR(100),
	Imagem			VARCHAR(MAX),
	StatusProduto	BIT NOT NULL DEFAULT 1, -- Produto j� vai ser cadastrado como ativo
	CategoriaID		INT NOT NULL,
	LocalizacaoID	INT NOT NULL,
	UsuarioID		UNIQUEIDENTIFIER NOT NULL,

	CONSTRAINT FK_Produto_Categoria
		FOREIGN KEY (CategoriaID) REFERENCES Categoria(CategoriaID),

	CONSTRAINT FK_Produto_Localizacao
		FOREIGN KEY (LocalizacaoID) REFERENCES Localizacao(LocalizacaoID),

	CONSTRAINT FK_Produto_Usuario
		FOREIGN KEY (UsuarioID) REFERENCES Usuario(UsuarioID)
);
GO

CREATE TABLE LogProduto (
	LogProdutoID			UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
	DataAlteracao			DATETIME2(0) NOT NULL,
	NomeAnterior			VARCHAR(100) NOT NULL,
	PrecoAnterior			DECIMAL(10,2) NOT NULL,
	StatusProduto			BIT NOT NULL,

	ProdutoID				UNIQUEIDENTIFIER NOT NULL,
	Codigo					INT NOT NULL,
	LocalizacaoIDAnterior	INT NOT NULL,
	UsuarioID				UNIQUEIDENTIFIER NOT NULL,

	CONSTRAINT FK_LogProduto_Produto
		FOREIGN KEY (ProdutoID) REFERENCES Produto(ProdutoID),

	CONSTRAINT FK_LogProduto_Codigo
		FOREIGN KEY (Codigo) REFERENCES Produto(Codigo),

	CONSTRAINT FK_LogProduto_Localizacao
		FOREIGN KEY (LocalizacaoIDAnterior) REFERENCES Localizacao(LocalizacaoID),

	CONSTRAINT FK_LogProduto_Usuario
		FOREIGN KEY (UsuarioID) REFERENCES Usuario(UsuarioID)
);
GO

CREATE TABLE Instituicoes (
InstituicoesID INT PRIMARY KEY,
NomeInstituicao VARCHAR (100) NOT NULL,
Missao NVARCHAR(MAX) NOT NULL,
Mes DATE NOT NULL
);
GO

---------- TRIGGERS E PROCEDURES ----------

-- Inativar usu�rio
 CREATE TRIGGER trg_ExclusaoUsuario
    ON Usuario
    INSTEAD OF DELETE 
    AS
    BEGIN
        UPDATE a SET StatusUsuario = 0
        FROM Usuario a 
        INNER JOIN deleted d 
            ON d.UsuarioID = a.UsuarioID;
    END
    GO

-- Criar registro na log
 CREATE TRIGGER trg_AlteracaoProduto
    ON Produto
    AFTER UPDATE
    AS
    BEGIN
        INSERT INTO LogProduto(DataAlteracao, ProdutoID, NomeAnterior, PrecoAnterior, StatusProduto, Codigo, LocalizacaoIDAnterior, UsuarioID)
        SELECT GETDATE(), ProdutoID, NomeProduto, Preco, StatusProduto, Codigo, LocalizacaoID, UsuarioID FROM deleted;
    END
	GO

-- Inativar produto
 CREATE TRIGGER trg_InativarProduto
    ON Produto
    INSTEAD OF DELETE 
    AS
    BEGIN
        UPDATE p SET StatusProduto= 0
        FROM Produto p 
        INNER JOIN deleted d 
            ON d.ProdutoID = p.ProdutoID;
    END
    GO

---------- POPULANDO BANCO ----------

-- TIPO PRODUTO --
INSERT INTO TipoProduto (NomeTipo) VALUES
('M�veis'),
('Vestu�rio'),
('Decora��o'),
('Literatura')
GO

-- LOCALIZA��O --
INSERT INTO Localizacao (NomeLocalizacao) VALUES
('Arara 1'),
('Arara 2'),
('Prateleira 1'),
('Prateleira 2'),
('Lavanderia'),
('Costureira')
GO

-- USU�RIO -- 
INSERT INTO Usuario (Nome, Email, Senha, Telefone) VALUES
('Carla Verano', 'carlaV@email.com',  HASHBYTES('SHA2_256', 'carla134'), '11987456321'),
('Anastasie Robustelli', 'anaTelli@email.com', HASHBYTES('SHA2_256', 'anastasie134'), '119123456789'),
('Lorena Snow', 'lore@email.com', HASHBYTES('SHA2_256', 'lorena134'), '119456871239')
GO

-- CATEGORIA --
INSERT INTO Categoria (NomeCategoria, TipoProdutoID) VALUES
('Arm�rio', 1),
('Prateleira', 1),
('Mesa', 1),
('Vestido', 2),
('Cal�a', 2),
('Camisa', 2),
('Vaso', 3),
('Quadro', 3),
('Tapete', 3),
('Gibi', 4),
('Revista', 4),
('Livro', 4)
GO

-- PRODUTO --
INSERT INTO Produto (NomeProduto, Preco, Descricao, Tamanho, Imagem, CategoriaID, LocalizacaoID, UsuarioID) VALUES
('Arm�rio retr�', 500.90, 'Arm�rio retr� azul e marrom com detalhes em dourado, duas portas e 4 gavetas. Restaurado.', '1,80m de altura e 1m de comprimento', NULL, 1, 4,( SELECT UsuarioID FROM Usuario WHERE Nome = 'Lorena Snow')),
('Regata banda de rock', 30.20, 'Regata do Linkin Park desbotada', 'M', NULL, 5, 1, ( SELECT UsuarioID FROM Usuario WHERE Nome = 'Lorena Snow')),
('Vaso Kintsugi', 400.10, 'Vaso chin�s consertado com t�cnica Kintsugi. Branco com detalhes azuis', 'Largura 19cm, Altura 25,5cm, Peso 789g', NULL, 6, 3, ( SELECT UsuarioID FROM Usuario WHERE Nome = 'Lorena Snow')),
('Mem�rias p�stumas de Bras Cubas', 20.50, 'Mem�rias P�stumas de Br�s Cubas, publicado por Machado de Assis em 1881, � narrado pelo pr�prio protagonista ap�s sua morte, o defunto autor.  
A obra inicia-se com a morte de Br�s Cubas e seu del�rio final, antes de relatar sua vida de forma n�o linear, marcada pela ironia e pessimismo.', '320 p�ginas', NULL, 11, 2, ( SELECT UsuarioID FROM Usuario WHERE Nome = 'Lorena Snow'))
GO

-- INSTITUIÇÕES --
INSERT INTO Instituicoes (NomeInstituicao, Missao, Mes) VALUES
('Tucca', 'Associação sem fins lucrativos 100% dedicada a oferecer assistência multidisciplinar de excelência para crianças e 
adolescentes de baixa renda com câncer por meio do cuidado integral.', '01-08-2025'),
('Obras Sociais Irmã Dulce', 'Trabalho extenso e gratuito nas áreas de saúde, educação e assistência social.', '01-09-2025'),
('Casa Hope', 'Apoio biopsicossocial e educacional à crianças e adolescentes portadores de câncer e transplantados de medula óssea, 
figado e rins, juntamente com seus acompanhantes.', '01-10-2025');

-- ALTERA��ES --

-- Mudando o tipo de imagem
ALTER TABLE Produto
DROP COLUMN Imagem;
GO

ALTER TABLE Produto
ADD Imagem VARBINARY(MAX);
GO
