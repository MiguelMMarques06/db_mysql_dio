-- CRIAÇÃO DO BANCO
create database if not exists ecommerce;
use ecommerce;

-- TABELA CLIENTE GENÉRICA
create table client(
	idClient int auto_increment primary key,
	fname varchar(50),
    minit char(3),
    lname varchar(50),
    address varchar(70)
);

-- TABELA CLIENTE PESSOA JURÍDICA
create table client_pj(
	idClient_PJ int primary key,
    cnpj char(14) not null unique,
    constraint fk_idClient_pj foreign key (idClient_PJ) references client(idClient)
);

-- TABELA CLIENTE PESSOA FÍSICA
create table client_pf(
	idClient_PF int primary key,
    cpf char(11) not null unique,
    constraint fk_idClient_pf foreign key (idClient_PF) references client(idClient)
);

-- CLIENTES
insert into client (fname, minit, lname, address) values
('Maria', 'M', 'Silva', 'Rua Silva de Prata 29, Carangola'),
('Matheus', 'O', 'Pimentel', 'Rua Alameda 289, Centro'),
('Ricardo', 'F', 'Silva', 'Avenida Vinha 1009, Centro'),
('Julia', 'S', 'França', 'Rua Lareiras 861, Centro'),
('Roberta', 'G', 'Assis', 'Avenida Koller 19, Centro'),
('Isabela', 'M', 'Cruz', 'Rua Flores 28, Centro');

insert into client_pf (idClient_PF, cpf) values
(1, '12345678901'),
(2, '98765432100'),
(3, '45678913000'),
(4, '78912345600'),
(5, '98745631000'),
(6, '65478912300');

-- TABELA PRODUTO
create table product(
	idProduct int auto_increment primary key,
	pname varchar(100) not null,
    classification_kids boolean default false,
    category enum('Eletrônico','Vestimenta','Brinquedos','Alimentos','Móveis') not null,
    avaliation float default 0,
    size varchar(20)
);

insert into product (pname, classification_kids, category, avaliation, size) values
('Smartphone', false, 'Eletrônico', 4.5, 'Médio'),
('Camiseta', false, 'Vestimenta', 4.0, 'M'),
('Boneca', true, 'Brinquedos', 4.8, 'Pequeno'),
('Chocolate', false, 'Alimentos', 4.7, 'Pequeno'),
('Sofá', false, 'Móveis', 4.2, 'Grande');

-- MÉTODOS DE PAGAMENTO
create table paymentMethod (
    idPaymentMethod int auto_increment primary key,
    typePayment enum('Boleto', 'Cartão', 'Dois cartões', 'PIX', 'Dinheiro') not null
);

insert into paymentMethod (typePayment) values
('Boleto'), ('Cartão'), ('Dois cartões'), ('PIX'), ('Dinheiro');

-- TABELA PAGAMENTOS
create table payments(
	idPayment int auto_increment primary key,
    idClient int,
    limitAvailable float,
    constraint fk_payment_client foreign key (idClient) references client(idClient) on update cascade on delete cascade
);

insert into payments (idClient, limitAvailable) values
(1, 5000),
(2, 3000),
(3, 2000),
(4, 1500);

-- PEDIDOS
create table orders(
	idOrder int auto_increment primary key,
    idOrderClient int,
    orderStatus enum('Cancelado','Confirmado','Em processamento') default 'Em processamento',
    orderDescription varchar(255),
    sendValue float default 0,
    paymentCash boolean default false,
	constraint fk_order_client foreign key (idOrderClient) references client(idClient) on update cascade on delete set null
);

insert into orders (idOrderClient, orderStatus, orderDescription, sendValue, paymentCash) values
(1, default, 'Compra via aplicativo', 0, 1),
(2, 'Confirmado', 'Compra via site', 50, 0),
(3, 'Em processamento', 'Compra via telefone', 150, 0);

-- RELAÇÃO PEDIDO PAGAMENTO
create table orderPayment (
	idOrder int,
    idPaymentMethod int,
    amountPaid float not null,
    primary key (idOrder, idPaymentMethod),
    foreign key (idOrder) references orders(idOrder),
    foreign key (idPaymentMethod) references paymentMethod(idPaymentMethod)
);

insert into orderPayment (idOrder, idPaymentMethod, amountPaid) values
(1, 2, 500),
(1, 4, 500),
(2, 1, 50),
(3, 3, 150);

-- ENTREGA
create table delivery(
	idDelivery int auto_increment,
    tracking_code varchar(10),
    idOrderD int,
    status_delivery enum ('Coletado','Em transfêrencia','Em centro de distribuição','Em rota','Entregue') default 'Coletado' not null,
    primary key(idDelivery, idOrderD),
    foreign key (idOrderD) references orders(idOrder)
);

-- ARMAZENAGEM
create table productStorage(
	idProdStorage int auto_increment primary key,
    storageLocation varchar(255),
    quantity int default 0
);

insert into productStorage (storageLocation, quantity) values
('Armazém Central', 100),
('Loja 1', 50),
('Loja 2', 30);

-- FORNECEDORES
create table supplier(
	idSupplier int auto_increment primary key,
    socialName varchar(255) not null,
    cnpj char(14) not null unique,
    contact char(11) not null
);

insert into supplier (socialName, cnpj, contact) values
('TechEletronicos', '12345678000199', '11999998888'),
('FashionVest', '98765432000155', '11988887777');

-- VENDEDORES
create table seller(
	idSeller int auto_increment primary key,
    socialName varchar(255) not null,
    abstName varchar(255),
    cnpj char(14) unique,
    cpf char(11) unique,
    location varchar(255),
    contact char(11) not null
);

insert into seller (socialName, abstName, cnpj, cpf, location, contact) values
('LojaTech', 'LT', '11223344000155', null, 'Rua A', '11911112222'),
('ModaPlus', 'MP', null, '12312312300', 'Rua B', '11922223333');

-- PRODUTO x VENDEDOR
create table productSeller(
	idPseller int,
    idProduct int,
	prodQuantity int default 1,
    primary key (idPseller, idProduct),
    foreign key (idPseller) references seller(idSeller),
    foreign key (idProduct) references product(idProduct)
);

insert into productSeller (idPseller, idProduct, prodQuantity) values
(1, 1, 10),
(2, 2, 20),
(1, 3, 5);

-- PRODUTO x PEDIDO
create table productOrder (
    idPOproduct int,
    idPOorder int,
    poQuantity int default 1,
    poStatus enum('Disponível', 'Sem estoque') default 'Disponível',
    primary key (idPOproduct, idPOorder),
    foreign key (idPOproduct) references product(idProduct) on update cascade on delete cascade,
    foreign key (idPOorder) references orders(idOrder) on update cascade on delete cascade
);

insert into productOrder (idPOproduct, idPOorder, poQuantity, poStatus) values
(1, 1, 1, 'Disponível'),
(2, 2, 2, 'Sem estoque');

-- LOCALIZAÇÃO DOS PRODUTOS
create table storageLocation(
	idLproduct int,
    idLstorage int,
    location varchar(255) not null,
    primary key (idLproduct, idLstorage),
    foreign key (idLproduct) references product(idProduct),
    foreign key (idLstorage) references productStorage(idProdStorage)
);

insert into storageLocation (idLproduct, idLstorage, location) values
(1, 1, 'Prateleira A'), (2, 2, 'Prateleira B');

-- PRODUTO x FORNECEDOR
create table productSupplier(
	idPsSupplier int, 
    idPsProduct int,
    quantity int not null,
    primary key (idPsSupplier, idPsProduct),
    foreign key (idPsSupplier) references supplier(idSupplier),
    foreign key (idPsProduct) references product(idProduct)
);

-- QUERIES 

-- Query para listar os clientes e o número de pedidos
SELECT 
	c.idClient,
	CONCAT(c.fname,' ',c.minit,' ',c.lname) AS NomeCliente,
	COUNT(o.idOrder) AS QuantidadesPedidos
FROM
	client c
LEFT JOIN
	orders o ON c.idClient = o.idOrderClient
GROUP BY
	c.idClient, NomeCliente;

-- Query para verificar vendedores que também são fornecedores via CNPJ
SELECT
	s.cnpj AS CNPJVendedor,
    s.socialName AS NomeVendedor
FROM
    seller s
INNER JOIN 
	supplier u ON s.cnpj = u.cnpj;

--  Query Completa: Produtos + Fornecedores + Estoques
SELECT
    p.idProduct,
    p.pname AS Produto,
    s.idSupplier,
    s.socialName AS Fornecedor,
    ps.quantity AS QuantidadeFornecida,
    psup.quantity AS QuantidadeEstoque,
    st.storageLocation AS LocalEstoque
FROM
    product p
INNER JOIN
    productSupplier psup ON p.idProduct = psup.idPsProduct
INNER JOIN
    supplier s ON psup.idPsSupplier = s.idSupplier
LEFT JOIN
    productStorage st ON p.idProduct = st.idProdStorage
LEFT JOIN
    productSupplier ps ON p.idProduct = ps.idPsProduct AND s.idSupplier = ps.idPsSupplier
ORDER BY
    p.idProduct;


-- Query para listar nomes dos fornecedores e nomes dos produtos
SELECT
	s.SocialName AS Fornecedor,
    p.pname AS Produto
FROM
	productSupplier AS psup
INNER JOIN
	supplier s ON s.idSupplier = psup.idPsSupplier
INNER JOIN
	product p ON psup.idPsProduct = p.idProduct
ORDER BY s.SocialName;

-- Query com HAVING para listar fornecedores que fornecem 1 ou mais produtos
SELECT 
    s.socialName AS Fornecedor,
    COUNT(ps.idPsProduct) AS Total_Produtos
FROM 
    productSupplier ps
INNER JOIN 
    supplier s ON ps.idPsSupplier = s.idSupplier
GROUP BY 
    s.socialName
HAVING 
    COUNT(ps.idPsProduct) > 0;
