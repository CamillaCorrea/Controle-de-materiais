use controlemateriais_db;


create table materiais (
    id int identity(1,1) primary key,
    nome varchar(250) not null,
    descricao varchar(max),
    medida varchar(25) not null,
    estoque_minimo int default 0,
    ativo bit not null default 1);

create table fornecedores (
    id int identity(1,1) primary key,
    nome varchar(250) not null,
    contato varchar(250),
    telefone varchar(25),
    ativo bit not null default 1);


create table entradas (
    id int identity(1,1) primary key,
    id_material int not null,
    id_fornecedor int not null,
    data_entrada date not null,
    quantidade int not null,
    preco decimal(10,2) not null,
    nota_fiscal varchar(50),

    constraint fk_entradas_materiais
        foreign key (id_material)
        references materiais(id),

    constraint fk_entradas_fornecedores
        foreign key (id_fornecedor)
        references fornecedores(id));

create table saidas (
    id int identity(1,1) primary key,
    id_material int not null,
    data_saida date not null,
    quantidade int not null,
    destino varchar(50),

    constraint fk_saidas_materiais
        foreign key (id_material)
        references materiais(id));


insert into materiais
(nome, descricao, medida, estoque_minimo, ativo)
values
('chapa de aluminio', 'chapa de aluminio de liga 6061-t6', 'm2', 100, 1),
('tubo de titanio', 'tubo de titanio grau 5', 'm', 50, 1),
('parafuso de aco inoxidavel', 'parafuso de aco inoxidavel aisi 316', 'unidade', 200, 1),
('fio de cobre', 'fio de cobre esmaltado', 'm', 150, 1),
('rebite de aluminio', 'rebite de aluminio solido', 'unidade', 300, 1),
('chapa de fibra de carbono', 'chapa de fibra de carbono pre-impregnada', 'm2', 80, 1),
('resina epoxi', 'resina epoxi para laminacao', 'kg', 40, 1),
('tecido de fibra de vidro', 'tecido de fibra de vidro para laminacao', 'm2', 120, 1),
('pintura poliuretanica', 'pintura poliuretanica para aeronaves', 'l', 30, 1),
('adesivo estrutural', 'adesivo estrutural de alta resistencia', 'kg', 25, 1);


insert into fornecedores
(nome, contato, telefone, ativo)
values
('aerometalurgica do sudeste', 'joao silva', '(11) 9999-9999', 1),
('titanio do brasil', 'maria souza', '(21) 3333-3333', 1),
('fixadores industriais', 'pedro santos', '(31) 2222-2222', 1),
('condutor eletrico', 'ana oliveira', '(41) 5555-5555', 1),
('rebites e fixadores', 'carlos rodrigues', '(19) 8888-8888', 1),
('fibra e carbono technology', 'juliana almeida', '(11) 4444-4444', 1),
('epoxi e compostos', 'roberto mendes', '(27) 7777-7777', 1),
('fibra de vidro do brasil', 'fernanda costa', '(48) 6666-6666', 1),
('tintas aeronauticas', 'marcelo santos', '(11) 2222-2222', 1),
('adesivos especiais', 'patricia lima', '(47) 9999-9999', 1);


create procedure registrar_entrada
    @id_material int,
    @id_fornecedor int,
    @data_entrada date,
    @quantidade int,
    @preco decimal(10,2),
    @nota_fiscal varchar(50)
as
begin
    insert into entradas (
        id_material,
        id_fornecedor,
        data_entrada,
        quantidade,
        preco,
        nota_fiscal
    )
    values (
        @id_material,
        @id_fornecedor,
        @data_entrada,
        @quantidade,
        @preco,
        @nota_fiscal
    );
end;


exec registrar_entrada
    @id_material = 1,
    @id_fornecedor = 1,
    @data_entrada = '2023-10-25',
    @quantidade = 100,
    @preco = 5.50,
    @nota_fiscal = 'nf001';


exec registrar_entrada
    @id_material = 2,
    @id_fornecedor = 2,
    @data_entrada = '2023-10-26',
    @quantidade = 50,
    @preco = 12.00,
    @nota_fiscal = 'nf002';


exec registrar_entrada
    @id_material = 7,
    @id_fornecedor = 7,
    @data_entrada = '2023-10-27',
    @quantidade = 40,
    @preco = 18.90,
    @nota_fiscal = 'nf150';


create procedure registrar_saida
    @id_material int,
    @data_saida date,
    @quantidade int,
    @destino varchar(50)
as
begin
    insert into saidas (
        id_material,
        data_saida,
        quantidade,
        destino
    )
    values (
        @id_material,
        @data_saida,
        @quantidade,
        @destino
    );
end;


exec registrar_saida
    @id_material = 3,
    @data_saida = '2023-11-01',
    @quantidade = 50,
    @destino = 'op003';


exec registrar_saida
    @id_material = 6,
    @data_saida = '2023-11-05',
    @quantidade = 20,
    @destino = 'op010';


create procedure inativar_material
    @id_material int
as
begin
    update materiais
    set ativo = 0
    where id = @id_material;
end;


exec inativar_material @id_material = 4;


exec inativar_material @id_material = 10;


create procedure inativar_fornecedor
    @id_fornecedor int
as
begin
    update fornecedores
    set ativo = 0
    where id = @id_fornecedor;
end;


exec inativar_fornecedor @id_fornecedor = 4;


exec inativar_fornecedor @id_fornecedor = 10;


create function calcular_estoque
(
    @id_material int
)
returns int
as
begin
    declare @total_entradas int;
    declare @total_saidas int;

    select @total_entradas = isnull(sum(quantidade), 0)
    from entradas
    where id_material = @id_material;

    select @total_saidas = isnull(sum(quantidade), 0)
    from saidas
    where id_material = @id_material;

    return @total_entradas - @total_saidas;
end;


select
    dbo.calcular_estoque(1) as estoque_material_1,
    dbo.calcular_estoque(2) as estoque_material_2,
    dbo.calcular_estoque(7) as estoque_material_7;


create view consultar_estoque
as
select
    id,
    nome,
    medida,
    estoque_minimo,
    dbo.calcular_estoque(id) as estoque_atual
from materiais;


select *
from consultar_estoque
order by nome;


select *
from materiais;


select *
from fornecedores;


select *
from entradas;


select *
from saidas;

