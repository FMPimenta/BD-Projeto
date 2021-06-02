DROP TABLE IF EXISTS desempenha;
DROP TABLE IF EXISTS sessao_teatro;
DROP TABLE IF EXISTS elenco;
DROP TABLE IF EXISTS personagem;
DROP TABLE IF EXISTS actor;
DROP TABLE IF EXISTS peca_teatro;

-- ----------------------------------------------------------------------

CREATE TABLE peca_teatro(
  codigo        NUMERIC(6),
  titulo        VARCHAR(50)     NOT NULL,
  descricao     VARCHAR(250)    NOT NULL,
  tipo          CHAR(1)         NOT NULL,
  ano           NUMERIC(4)      NOT NULL, -- ano em que foi criada
  duracao       NUMERIC(3)      NOT NULL, -- em minutos
  encenador     VARCHAR(30),              -- enc. solucao minimalista (nao a ideal)
--
  CONSTRAINT pk_peca_teatro
    PRIMARY KEY (codigo),
--
  CONSTRAINT ck_peca_teatro_codigo
    CHECK (codigo BETWEEN 1 AND 999999),
--
  CONSTRAINT ck_peca_teatro_tipo
    CHECK (tipo IN (‘T’,‘M’)), 		  -- tipo: (T)radicional ou (M)usical
--
  CONSTRAINT ck_peca_teatro_ano
    CHECK (ano BETWEEN 1900 AND 2100), 
--
  CONSTRAINT ck_peca_teatro_duracao
    CHECK (duracao BETWEEN 30 AND 999)    -- 30 minutos no mínimo
);

CREATE TABLE actor(
  id            NUMERIC(8),
  nome          VARCHAR(40)     NOT NULL,
  nif           NUMERIC(9),
  genero        CHAR(1)         NOT NULL,
  nasc          NUMERIC(4)      NOT NULL, -- ano de nascimento
  actividade    NUMERIC(4)      NOT NULL, -- ano de início de actividade
  padrinho      NUMERIC(8),		  -- a existir, é outro actor

--
  CONSTRAINT pk_actor
    PRIMARY KEY (id),
--
  CONSTRAINT fk_actor_padrinho
    FOREIGN KEY (padrinho) REFERENCES actor (id),
--
  CONSTRAINT ck_actor_id
    CHECK (id BETWEEN 1 AND 99999999),
--
  CONSTRAINT ck_actor_nif
    CHECK (nif BETWEEN 1 AND 999999999),
--
  CONSTRAINT un_actor_nif       	 -- NIF unico
    UNIQUE (nif),
--
  CONSTRAINT ck_actor_genero
    CHECK (genero IN (‘F’,‘M’)),
--
  CONSTRAINT ck_actor_nasc
    CHECK (nasc BETWEEN 1900 AND 2100), 
--
  CONSTRAINT ck_actor_actividade
    CHECK (actividade BETWEEN 1900 AND 2100), 
--
  CONSTRAINT ck_actor_actividade_nasc
    CHECK (actividade > nasc),
--
  CONSTRAINT ck_actor_padrinho
    CHECK (id <> padrinho)
);

CREATE TABLE personagem(
  peca_teatro   NUMERIC(6),
  nome          CHAR(20),
  cachet        NUMERIC(3)      NOT NULL, -- percentagem para actor
--
  CONSTRAINT pk_personagem
    PRIMARY KEY (peca_teatro,nome),
--
  CONSTRAINT fk_personagem_peca_teatro
    FOREIGN KEY (peca_teatro)
    REFERENCES peca_teatro (codigo) ON DELETE CASCADE,
--
  CONSTRAINT ck_personagem_cachet
    CHECK (cachet BETWEEN 0 AND 100)
);

CREATE TABLE elenco(		      
  peca_teatro   NUMERIC(6), 
  personagem    CHAR(20), 
  actor         NUMERIC(8),             
--                                    
  CONSTRAINT pk_elenco        
    PRIMARY KEY (peca_teatro,personagem,actor),  
--
  CONSTRAINT fk_elenco_personagem
    FOREIGN KEY (peca_teatro,personagem)
    REFERENCES personagem (peca_teatro,nome),

--
  CONSTRAINT fk_elenco_actor
    FOREIGN KEY (actor) REFERENCES actor (id)
);



CREATE TABLE sessao_teatro( 
  peca_teatro   NUMERIC(6), 
  seq           NUMERIC(4),
  data          DATE            NOT NULL, 	 
  cachet        NUMERIC(6,2)    NOT NULL,
--
  CONSTRAINT pk_sessao_teatro
    PRIMARY KEY (peca_teatro,seq),
--
  CONSTRAINT fk_sessao_teatro_peca
    FOREIGN KEY (peca_teatro)
    REFERENCES peca_teatro (codigo) ON DELETE CASCADE,
--
  CONSTRAINT ck_sessao_teatro_seq	 
    CHECK (seq > 0),
--
  CONSTRAINT ck_sessao_teatro_data
    CHECK (TO_CHAR(data,‘YYYY’) BETWEEN 1900 AND 2100), -- no oracle 
    -- e conversao p/ numero implicita. No MySQL: DATE_FORMAT(date,’%Y’)    
    -- ou YEAR(date), para string ou num, mas CHECKS ignorados =>triggers
--
  CONSTRAINT ck_sessao_teatro_cachet	 
    CHECK (cachet > 0)
);

CREATE TABLE desempenha(
  peca_sessao   NUMERIC(6), 
  seq_sessao    NUMERIC(4),
  peca_person   NUMERIC(6),
  personagem    CHAR(20),
  actor         NUMERIC(8),
--
  CONSTRAINT pk_desempenha
    PRIMARY KEY (peca_sessao,seq_sessao,actor,peca_person,personagem),
--
  CONSTRAINT fk_desempenha_sessao
    FOREIGN KEY (peca_sessao,seq_sessao)
    REFERENCES sessao_teatro (peca_teatro,seq),
--
  CONSTRAINT fk_desempenha_elenco
    FOREIGN KEY (peca_person,personagem,actor)
    REFERENCES elenco (peca_teatro,personagem,actor),
--
  CONSTRAINT ck_sessao_teatro_seq	 
    CHECK (peca_sessao = peca_person)
);




-- PECA DE TEATRO


INSERT INTO peca_teatro (codigo,titulo,tipo,ano, duracao,encenador) 
     VALUES (1,"Cats","M",1981, 140, "Andrew");
INSERT INTO peca_teatro (codigo,titulo,tipo,ano, duracao,encenador) 
     VALUES (2,"My Fair Lady","T", 2003, 120, "Filipe La Féria");
INSERT INTO peca_teatro (codigo,titulo,tipo,ano, duracao,encenador) 
     VALUES (3,"Mood Swings","M",2020, 34, "Pop Smoke");
INSERT INTO peca_teatro (codigo,titulo,tipo,ano, duracao,encenador) 
     VALUES (4,"Auto da Barca","T", 2009, 130, "Gil Vicente");
INSERT INTO peca_teatro (codigo,titulo,tipo,ano, duracao,encenador) 
     VALUES (5,"Romeu e Julieta","T", 1560, 130, "Shakespeare");
INSERT INTO peca_teatro (codigo,titulo,tipo,ano, duracao,encenador) 
     VALUES (7,"Musical Oxford","M", 2004, 110, "Filipe La Féria");
     
-- ATOR


INSERT INTO actor (id,nome,nif,genero,nasc,actividade) 
     VALUES (21,"Miguel","190251171","M", 1960, 1980);
INSERT INTO actor (id,nome,nif,genero,nasc,actividade) 
     VALUES (14,"Pedro","190257792","M", 2001, 2019);
INSERT INTO actor (id,nome,nif,genero,nasc,actividade) 
     VALUES (7,"Ronaldo","193257222","M", 1985, 2000);
INSERT INTO actor (id,nome,nif,genero,nasc,actividade) 
     VALUES (23,"LeBron James","191157792","M", 1990, 2002);
INSERT INTO actor (id,nome,nif,genero,nasc,actividade) 
     VALUES (45,"Ticha Penicheiro","190447792","F", 1982, 1990);
INSERT INTO actor (id,nome,nif,genero,nasc,actividade) 
     VALUES (55,"Ana Silva","190250000","F", 1973, 2000);


INSERT INTO actor (id,nome,nif,genero,nasc,actividade) 
     VALUES (2,"Isabel","190000071","F", 1999, 2017);
INSERT INTO actor (id,nome,nif,genero,nasc,actividade) 
     VALUES (3,"Chico Tines","100057222","M", 2000, 2020);
INSERT INTO actor (id,nome,nif,genero,nasc,actividade) 
     VALUES (4,"Anthony","122257792","M", 1949, 1969);
INSERT INTO actor (id,nome,nif,genero,nasc,actividade) 
     VALUES (5,"Sofia","190411112","F", 1980, 1990);
INSERT INTO actor (id,nome,nif,genero,nasc,actividade) 
     VALUES (6,"Faísca","191234520","M", 1912, 1940);
INSERT INTO actor (id,nome,nif,genero,nasc,actividade) 
     VALUES (1,"Logan Paul","492342520","M", 1996, 2010);

INSERT INTO actor (id,nome,nif,genero,nasc,actividade) 
     VALUES (12,"Roman Atwood","243242520","M", 1985, 2000);

INSERT INTO actor (id,nome,nif,genero,nasc,actividade) 
     VALUES (93,"Ruy de Carvalho","194274364","M", 1927, 1940);

INSERT INTO actor (id,nome,nif,genero,nasc,actividade) 
     VALUES (56,"Mamadomecu","492300020","M", 1986, 2003);

INSERT INTO actor (id,nome,nif,genero,nasc,actividade) 
     VALUES (28,"Mamasabira","490000020","F", 1990, 2003);
INSERT INTO actor (id,nome,nif,genero,nasc,actividade) 
     VALUES (18,"Ticha Penicheiro","490550020","F", 1970, 1987);

-- PERSONAGEM

INSERT INTO personagem (peca_teatro,nome,cachet) 
     VALUES (1, "Grizabella", 20);
INSERT INTO personagem (peca_teatro,nome,cachet) 
     VALUES (1, "Mistoffelees", 10);
INSERT INTO personagem (peca_teatro,nome,cachet) 
     VALUES (1, "Rum Tum Tugger", 17);


INSERT INTO personagem (peca_teatro,nome,cachet) 
     VALUES (2, "Alfred P. Doolittle", 5);
INSERT INTO personagem (peca_teatro,nome,cachet) 
     VALUES (2, "Eliza Doolittle", 3);
INSERT INTO personagem (peca_teatro,nome,cachet) 
     VALUES (2, "Prof Henry Higgins", 5);


INSERT INTO personagem (peca_teatro,nome,cachet) 
     VALUES (3, "Pop Smoke", 70);
INSERT INTO personagem (peca_teatro,nome,cachet) 
     VALUES (3, "Lil Tjay", 26);
INSERT INTO personagem (peca_teatro,nome,cachet) 
     VALUES (3, "Amalia", 1);
INSERT INTO personagem (peca_teatro,nome,cachet) 
     VALUES (3, "Drake", 1);


INSERT INTO personagem (peca_teatro,nome,cachet) 
     VALUES (5, "Romeu", 42);
INSERT INTO personagem (peca_teatro,nome,cachet) 
     VALUES (5, "Julieta", 43);
INSERT INTO personagem (peca_teatro,nome,cachet) 
     VALUES (5, "Teobaldo", 44);
INSERT INTO personagem (peca_teatro,nome,cachet) 
     VALUES (5, "Judeu", 3);


INSERT INTO personagem (peca_teatro,nome,cachet) 
     VALUES (4, "Sapateiro", 3);
INSERT INTO personagem (peca_teatro,nome,cachet) 
     VALUES (4, "Parvo", 3);
INSERT INTO personagem (peca_teatro,nome,cachet) 
     VALUES (4, "Fidalgo", 3);
INSERT INTO personagem (peca_teatro,nome,cachet) 
     VALUES (4, "Alcoviteira", 3);

INSERT INTO personagem (peca_teatro,nome,cachet) 
     VALUES (7, "Saxofonista", 6);
INSERT INTO personagem (peca_teatro,nome,cachet) 
     VALUES (7, "Pianista", 24);

-- ELENCO 

INSERT INTO elenco (peca_teatro,personagem,actor) 
     VALUES (3, "Pop Smoke", 4);
INSERT INTO elenco (peca_teatro,personagem,actor) 
     VALUES (3, "Lil Tjay", 3);
INSERT INTO elenco (peca_teatro,personagem,actor) 
     VALUES (3, "Amalia", 5);
INSERT INTO elenco (peca_teatro,personagem,actor) 
     VALUES (3, "Drake", 12);

INSERT INTO elenco (peca_teatro,personagem,actor) 
     VALUES (5, "Romeu", 6);
INSERT INTO elenco (peca_teatro,personagem,actor) 
     VALUES (5, "Julieta", 1);
INSERT INTO elenco (peca_teatro,personagem,actor) 
     VALUES (5, "Teobaldo", 2);
INSERT INTO elenco (peca_teatro,personagem,actor) 
     VALUES (5, "Judeu", 12);
INSERT INTO elenco (peca_teatro,personagem,actor) 
     VALUES (5, "Julieta", 18);


INSERT INTO elenco (peca_teatro,personagem,actor) 
     VALUES (2, "Eliza Doolittle", 45);
INSERT INTO elenco (peca_teatro,personagem,actor) 
     VALUES (2, "Alfred P. Doolittle", 7);
INSERT INTO elenco (peca_teatro,personagem,actor) 
     VALUES (2, "Prof Henry Higgins", 23);


INSERT INTO elenco (peca_teatro,personagem,actor) 
     VALUES (1, "Grizabella", 55);
INSERT INTO elenco (peca_teatro,personagem,actor) 
     VALUES (1, "Mistoffelees", 14);
INSERT INTO elenco (peca_teatro,personagem,actor) 
     VALUES (1, "Rum Tum Tugger", 21);

INSERT INTO elenco (peca_teatro,personagem,actor) 
     VALUES (7, "Pianista", 21);


      
INSERT INTO elenco (peca_teatro,personagem,actor) 
     VALUES (4, "Sapateiro", 12);
INSERT INTO elenco (peca_teatro,personagem,actor) 
     VALUES (4, "Alcoviteira", 28);
INSERT INTO elenco (peca_teatro,personagem,actor) 
     VALUES (4, "Fidalgo", 6);
INSERT INTO elenco (peca_teatro,personagem,actor) 
     VALUES (4, "Parvo", 1);

INSERT INTO elenco (peca_teatro,personagem,actor) 
     VALUES (7, "Saxofonista", 56);


-- SESSAO TEATRO


INSERT INTO sessao_teatro (peca_teatro,seq,data,cachet) 
     VALUES (5, 1, 2018, 20);

INSERT INTO sessao_teatro (peca_teatro,seq,data,cachet) 
     VALUES (2, 2, '2010', 30);
INSERT INTO sessao_teatro (peca_teatro,seq,data,cachet) 
     VALUES (3, 3, '2020', 70);
INSERT INTO sessao_teatro (peca_teatro,seq,data,cachet) 
     VALUES (4, 4, '2009', 15);
INSERT INTO sessao_teatro (peca_teatro,seq,data,cachet) 
     VALUES (5, 6, '2009-04-09', 19);
INSERT INTO sessao_teatro (peca_teatro,seq,data,cachet) 
     VALUES (5, 7, '2009-05-09', 19);
INSERT INTO sessao_teatro (peca_teatro,seq,data,cachet) 
     VALUES (5, 8, '2009-06-09', 19);


-- DESEMPENHA


INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (5, 1, 5, "Romeu", 6);
INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (5, 1, 5, "Julieta", 1);
INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (5, 1, 5, "Judeu", 12);
INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (5, 1, 5, "Teobaldo", 2);

INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (5, 6, 5, "Julieta", 18);

INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (5, 6, 5, "Romeu", 6);
INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (5, 6, 5, "Julieta", 1);
INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (5, 6, 5, "Judeu", 12);
INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (5, 6, 5, "Teobaldo", 2);

INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (5, 7, 5, "Romeu", 6);
INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (5, 7, 5, "Julieta", 1);
INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (5, 7, 5, "Judeu", 12);
INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (5, 7, 5, "Teobaldo", 2);     

INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (5, 8, 5, "Romeu", 6);
INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (5, 8, 5, "Julieta", 1);
INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (5, 8, 5, "Judeu", 12);
INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (5, 8, 5, "Teobaldo", 2);


INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (5, 5, 5, "Teobaldo", 2);
INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (5, 5, 5, "Judeu", 6);

INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (2, 2, 2, "Alfred P. Doolittle", 7);
INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (2, 2, 2, "Eliza Doolittle", 45);
INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (2, 2, 2, "Prof Henry Higgins", 23);

INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (3, 3, 3, "Drake", 12);
INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (3, 3, 3, "Pop Smoke", 4);
INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (3, 3, 3, "Lil Tjay", 3);
INSERT INTO desempenha (peca_sessao, seq_sessao, peca_person, personagem, actor) 
     VALUES (3, 3, 3, "Amalia", 5);


