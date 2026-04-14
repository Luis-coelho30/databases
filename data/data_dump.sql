-- =============================================================================
--  E-COMMERCE MARKETPLACE — Data Dump (Test Data)
--  Arquivo separado do schema para permitir reset independente dos dados
--
--  Ordem de inserção respeita dependências de FK:
--  user → customer / seller
--  customer → address | seller → seller_address / seller_balance
--  category (self-ref, raízes primeiro)
--  seller → product → product_variant → product_image
--  product + category → product_category
--  fee_rule
--  customer → orders → order_address / order_item / order_status_history
--  orders → payment → charge → charge_status_history
--                            → applied_fee (+ fee_rule)
--                            → settlement
--  seller → payout
-- =============================================================================

USE ecommerce_marketplace;

SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;

-- =============================================================================
-- SUB-DOMAIN: USER
-- 10 users: user_id 1-7 → customers | 8-12 → sellers
-- =============================================================================

INSERT INTO user (user_id, email, password_hash, phone_number) VALUES
  (1,  'ana.souza@email.com',      SHA2('senha@123', 256), '11991110001'),
  (2,  'bruno.lima@email.com',     SHA2('senha@123', 256), '21982220002'),
  (3,  'carla.mendes@email.com',   SHA2('senha@123', 256), '31973330003'),
  (4,  'diego.costa@email.com',    SHA2('senha@123', 256), '41964440004'),
  (5,  'eduarda.reis@email.com',   SHA2('senha@123', 256), '51955550005'),
  (6,  'felipe.neto@email.com',    SHA2('senha@123', 256), '61946660006'),
  (7,  'gabriela.tav@email.com',   SHA2('senha@123', 256), '71937770007'),
  -- sellers
  (8,  'contato@techstore.com.br', SHA2('seller@456', 256), '1133001100'),
  (9,  'vendas@modaexpress.com.br',SHA2('seller@456', 256), '2133002200'),
  (10, 'ola@casalar.com.br',       SHA2('seller@456', 256), '3133003300'),
  (11, 'sac@megaeletro.com.br',    SHA2('seller@456', 256), '4133004400'),
  (12, 'esportes@sportcia.com.br', SHA2('seller@456', 256), '5133005500');

-- =============================================================================
-- SUB-DOMAIN: USER — customer
-- =============================================================================

INSERT INTO customer (customer_id, full_name, cpf, birth_date) VALUES
  (1, 'Ana Souza',        '12345678901', '1992-03-15'),
  (2, 'Bruno Lima',       '23456789012', '1988-07-22'),
  (3, 'Carla Mendes',     '34567890123', '1995-11-05'),
  (4, 'Diego Costa',      '45678901234', '1990-01-30'),
  (5, 'Eduarda Reis',     '56789012345', '1998-06-18'),
  (6, 'Felipe Neto',      '67890123456', '1985-09-12'),
  (7, 'Gabriela Tavares', '78901234567', '2000-04-25');

-- =============================================================================
-- SUB-DOMAIN: USER — seller
-- =============================================================================

INSERT INTO seller (seller_id, legal_name, trade_name, cnpj, average_rating) VALUES
  (8,  'Tech Store Ltda',   'TechStore',   '11222333000181', 4.80),
  (9,  'Moda Express ME',   'ModaExpress', '22333444000172', 4.50),
  (10, 'Casa Lar Eireli',   'CasaLar',     '33444555000163', 4.70),
  (11, 'Mega Eletro S.A.',  'MegaEletro',  '44555666000154', 4.20),
  (12, 'Sport & Cia Ltda',  'SportCia',    '55666777000145', 4.60);

-- =============================================================================
-- SUB-DOMAIN: USER — address (customer)
-- Cada customer tem ao menos 1 endereço; alguns têm 2
-- =============================================================================

INSERT INTO address (address_id, customer_id, address_type, street, street_number, complement, neighborhood, city, state, postal_code, is_default) VALUES
  (1,  1, 'BOTH',     'Rua das Flores',       '123', 'Apto 42',  'Jardim Paulista', 'São Paulo',      'SP', '01452000', TRUE),
  (2,  1, 'DELIVERY', 'Av. Paulista',          '900', 'Sala 5',   'Bela Vista',      'São Paulo',      'SP', '01310100', FALSE),
  (3,  2, 'BOTH',     'Rua do Catete',         '250',  NULL,      'Catete',          'Rio de Janeiro', 'RJ', '22220000', TRUE),
  (4,  3, 'BOTH',     'Av. Afonso Pena',       '500', 'Bloco B',  'Centro',          'Belo Horizonte', 'MG', '30130001', TRUE),
  (5,  4, 'DELIVERY', 'Rua XV de Novembro',    '88',   NULL,      'Centro',          'Curitiba',       'PR', '80020310', TRUE),
  (6,  5, 'BOTH',     'Av. Mauá',              '10',  'Casa',     'Navegantes',      'Porto Alegre',   'RS', '90220080', TRUE),
  (7,  6, 'BOTH',     'SQN 205 Bloco G',       '301',  NULL,      'Asa Norte',       'Brasília',       'DF', '70843070', TRUE),
  (8,  7, 'DELIVERY', 'Rua da Consolação',    '3000', 'Apto 11',  'Consolação',      'São Paulo',      'SP', '01416001', TRUE),
  (9,  2, 'BILLING',  'Rua Voluntários Pátria','780',  NULL,      'Botafogo',        'Rio de Janeiro', 'RJ', '22270010', FALSE),
  (10, 5, 'BILLING',  'Rua dos Andradas',      '500',  NULL,      'Centro Histórico','Porto Alegre',   'RS', '90020005', FALSE);

-- =============================================================================
-- SUB-DOMAIN: USER — seller_address
-- =============================================================================

INSERT INTO seller_address (seller_address_id, seller_id, address_type, street, street_number, complement, neighborhood, city, state, postal_code, is_main) VALUES
  (1,  8,  'STORE',     'Rua Funchal',         '418', 'Loja 3',  'Vila Olímpia',    'São Paulo',      'SP', '04551060', TRUE),
  (2,  8,  'WAREHOUSE', 'Rod. Anhanguera',      'Km 22', NULL,    'Cumbica',         'Guarulhos',      'SP', '07180000', FALSE),
  (3,  9,  'STORE',     'Rua Visconde Pirajá',  '351',   NULL,    'Ipanema',         'Rio de Janeiro', 'RJ', '22410003', TRUE),
  (4,  9,  'FISCAL',    'Av. Rio Branco',        '85',   NULL,    'Centro',          'Rio de Janeiro', 'RJ', '20040004', FALSE),
  (5,  10, 'STORE',     'Av. Raja Gabaglia',    '1000',  NULL,    'Luxemburgo',      'Belo Horizonte', 'MG', '30380090', TRUE),
  (6,  11, 'STORE',     'Av. João Naves Ávila', '1331',  NULL,    'Tibery',          'Uberlândia',     'MG', '38408100', TRUE),
  (7,  11, 'WAREHOUSE', 'Av. Circular',          '200',  NULL,    'Distrito Industrial','Uberlândia',  'MG', '38402018', FALSE),
  (8,  12, 'STORE',     'Av. Bento Gonçalves',  '2200',  NULL,    'Partenon',        'Porto Alegre',   'RS', '91530001', TRUE),
  (9,  10, 'WAREHOUSE', 'Rua Padre Eustáquio',   '330',  NULL,    'Padre Eustáquio', 'Belo Horizonte', 'MG', '30720100', FALSE),
  (10, 12, 'FISCAL',    'Av. Assis Brasil',      '800',  NULL,    'Passo D\'Areia',  'Porto Alegre',   'RS', '91010000', FALSE);

-- =============================================================================
-- SUB-DOMAIN: CATALOG — category
-- Raízes primeiro (parent_id NULL), filhos depois
-- =============================================================================

INSERT INTO category (category_id, category_name, parent_id) VALUES
  -- raízes
  (1,  'Eletrônicos',   NULL),
  (2,  'Moda',          NULL),
  (3,  'Casa & Jardim', NULL),
  (4,  'Esportes',      NULL),
  -- filhos
  (5,  'Smartphones',   1),
  (6,  'Notebooks',     1),
  (7,  'Periféricos',   1),
  (8,  'Camisetas',     2),
  (9,  'Tênis',         2),
  (10, 'Cama & Banho',  3),
  (11, 'Ferramentas',   3),
  (12, 'Suplementos',   4),
  (13, 'Acessórios',    4);

-- =============================================================================
-- SUB-DOMAIN: CATALOG — product
-- Distribuídos entre os 5 sellers
-- =============================================================================

INSERT INTO product (product_id, seller_id, product_name, product_description, is_active) VALUES
  (1,  8,  'Samsung Galaxy S24 Ultra',  'Smartphone topo de linha, câmera 200MP, tela 6.8" AMOLED',          TRUE),
  (2,  8,  'Apple iPhone 15 Pro',        'Smartphone Apple, chip A17 Pro, tela 6.1" Super Retina XDR',        TRUE),
  (3,  11, 'Motorola Moto G84',           'Smartphone intermediário, tela 6.5" pOLED, bateria 5000mAh',       TRUE),
  (4,  8,  'Dell Inspiron 15',            'Notebook Intel i7 13ª geração, 16GB RAM, 512GB SSD',               TRUE),
  (5,  11, 'Lenovo IdeaPad 3',            'Notebook AMD Ryzen 5, 8GB RAM, 256GB SSD',                         TRUE),
  (6,  8,  'Monitor LG 27" 4K',           'Monitor IPS 4K UHD 60Hz, HDR10, altura ajustável',                 TRUE),
  (7,  8,  'Teclado Redragon Kumara',     'Teclado mecânico switch Red, RGB, ABNT2',                          TRUE),
  (8,  9,  'Camiseta Básica Masculina',   '100% algodão penteado, corte regular, disponível em várias cores', TRUE),
  (9,  9,  'Camiseta Básica Feminina',    '100% algodão penteado, corte slim fit',                            TRUE),
  (10, 9,  'Nike Air Max 270',             'Tênis casual com câmara Air no calcanhar, palmilha macia',         TRUE),
  (11, 10, 'Jogo de Cama Queen 300 Fios', 'Percal 300 fios, 4 peças, 100% algodão',                          TRUE),
  (12, 10, 'Furadeira de Impacto 650W',   'Bosch GSB 650, mandril 13mm, maleta incluída',                     TRUE);

-- =============================================================================
-- SUB-DOMAIN: CATALOG — product_variant
-- Cada produto tem ao menos 1 variante; alguns têm mais (cor/tamanho)
-- =============================================================================

INSERT INTO product_variant (variant_id, product_id, sku, price, stock_quantity, is_active) VALUES
  -- Galaxy S24 Ultra: 256GB e 512GB
  (1,  1,  'SAM-S24U-256-BLK', 6499.00,  30, TRUE),
  (2,  1,  'SAM-S24U-512-BLK', 7199.00,  15, TRUE),
  -- iPhone 15 Pro: 128GB e 256GB
  (3,  2,  'APL-15PRO-128-BLK', 7499.00, 20, TRUE),
  (4,  2,  'APL-15PRO-256-WHT', 7999.00, 12, TRUE),
  -- Moto G84: único SKU
  (5,  3,  'MOT-G84-256-GRA',   1699.00,  80, TRUE),
  -- Dell Inspiron
  (6,  4,  'DEL-INS15-512-SLV', 4299.00,  18, TRUE),
  -- Lenovo IdeaPad
  (7,  5,  'LEN-IP3-256-GRY',   2599.00,  25, TRUE),
  -- Monitor LG
  (8,  6,  'LGM-27-4K-BLK',     2199.00,  10, TRUE),
  -- Teclado Redragon
  (9,  7,  'RED-KUM-RGB-BLK',    299.00, 100, TRUE),
  -- Camiseta Masc: P, M, G
  (10, 8,  'HER-CM-P-WHT',        49.90, 200, TRUE),
  (11, 8,  'HER-CM-M-WHT',        49.90, 200, TRUE),
  (12, 8,  'HER-CM-G-BLK',        49.90, 150, TRUE),
  -- Camiseta Fem: P, M
  (13, 9,  'HER-CF-P-WHT',        44.90, 180, TRUE),
  (14, 9,  'HER-CF-M-PNK',        44.90, 160, TRUE),
  -- Nike Air Max 270: 40, 42, 44
  (15, 10, 'NIK-AM270-40-BLK',   549.00,  20, TRUE),
  (16, 10, 'NIK-AM270-42-BLK',   549.00,  25, TRUE),
  (17, 10, 'NIK-AM270-44-WHT',   549.00,  15, TRUE),
  -- Jogo de Cama
  (18, 11, 'BUD-JCQ-300-WHT',    259.00,  60, TRUE),
  -- Furadeira Bosch
  (19, 12, 'BOS-GSB650-KIT',     379.00,  45, TRUE);

-- =============================================================================
-- SUB-DOMAIN: CATALOG — product_image
-- =============================================================================

INSERT INTO product_image (image_id, variant_id, image_url, is_primary) VALUES
  (1,  1,  'https://cdn.mktplace.com/sam-s24u-256-blk-front.jpg',  TRUE),
  (2,  1,  'https://cdn.mktplace.com/sam-s24u-256-blk-back.jpg',   FALSE),
  (3,  3,  'https://cdn.mktplace.com/apl-15pro-128-blk-front.jpg', TRUE),
  (4,  4,  'https://cdn.mktplace.com/apl-15pro-256-wht-front.jpg', TRUE),
  (5,  5,  'https://cdn.mktplace.com/mot-g84-256-gra-front.jpg',   TRUE),
  (6,  6,  'https://cdn.mktplace.com/del-ins15-512-slv.jpg',       TRUE),
  (7,  7,  'https://cdn.mktplace.com/len-ip3-256-gry.jpg',         TRUE),
  (8,  8,  'https://cdn.mktplace.com/lgm-27-4k-blk-front.jpg',     TRUE),
  (9,  9,  'https://cdn.mktplace.com/red-kum-rgb-blk.jpg',         TRUE),
  (10, 10, 'https://cdn.mktplace.com/her-cm-p-wht.jpg',            TRUE),
  (11, 13, 'https://cdn.mktplace.com/her-cf-p-wht.jpg',            TRUE),
  (12, 16, 'https://cdn.mktplace.com/nik-am270-42-blk.jpg',        TRUE),
  (13, 18, 'https://cdn.mktplace.com/bud-jcq-300-wht.jpg',         TRUE),
  (14, 19, 'https://cdn.mktplace.com/bos-gsb650-kit.jpg',          TRUE),
  (15, 2,  'https://cdn.mktplace.com/sam-s24u-512-blk-front.jpg',  TRUE);

-- =============================================================================
-- SUB-DOMAIN: CATALOG — product_category
-- =============================================================================

INSERT INTO product_category (product_id, category_id) VALUES
  (1,  1), (1,  5),   -- Galaxy: Eletrônicos + Smartphones
  (2,  1), (2,  5),   -- iPhone: Eletrônicos + Smartphones
  (3,  1), (3,  5),   -- Moto G84: Eletrônicos + Smartphones
  (4,  1), (4,  6),   -- Dell: Eletrônicos + Notebooks
  (5,  1), (5,  6),   -- Lenovo: Eletrônicos + Notebooks
  (6,  1), (6,  7),   -- Monitor: Eletrônicos + Periféricos
  (7,  1), (7,  7),   -- Teclado: Eletrônicos + Periféricos
  (8,  2), (8,  8),   -- Camiseta Masc: Moda + Camisetas
  (9,  2), (9,  8),   -- Camiseta Fem: Moda + Camisetas
  (10, 2), (10, 9),   -- Nike: Moda + Tênis
  (11, 3), (11,10),   -- Jogo Cama: Casa & Jardim + Cama & Banho
  (12, 3), (12,11);   -- Furadeira: Casa & Jardim + Ferramentas

-- =============================================================================
-- SUB-DOMAIN: FINANCE — fee_rule
-- =============================================================================

INSERT INTO fee_rule (fee_rule_id, fee_name, fee_type, fee_value, min_amount, max_amount, is_active) VALUES
  (1,  'Taxa padrão marketplace',    'PERCENTAGE', 12.00, 2.00,  500.00, TRUE),
  (2,  'Taxa processamento Pix',     'FIXED',       0.00, NULL,    NULL, TRUE),
  (3,  'Taxa processamento boleto',  'FIXED',       3.50, NULL,    NULL, TRUE),
  (4,  'Taxa processamento cartão',  'PERCENTAGE',  2.50, 0.50,    NULL, TRUE),
  (5,  'Taxa promocional Q1 2024',   'PERCENTAGE',  8.00, 1.00,  200.00, FALSE);

-- =============================================================================
-- SUB-DOMAIN: ORDER — orders
-- 10 pedidos de 7 clientes em diferentes estados
-- delivery_address_id referencia order_address.address_id (enforced by application)
-- =============================================================================

INSERT INTO orders (order_id, customer_id, delivery_address_id, order_status, total_amount, created_at) VALUES
  (1,  1, 1,  'DELIVERED',  6798.00, '2024-01-15 09:45:00'),
  (2,  2, 3,  'SHIPPED',    4299.00, '2024-01-18 14:00:00'),
  (3,  3, 4,  'PROCESSING',  94.80, '2024-01-20 11:30:00'),
  (4,  4, 5,  'PAID',       7999.00, '2024-02-01 19:00:00'),
  (5,  5, 6,  'CREATED',     638.00, '2024-02-10 08:20:00'),
  (6,  6, 7,  'DELIVERED',   549.00, '2024-02-10 11:00:00'),
  (7,  7, 8,  'PROCESSING', 4798.00, '2024-02-15 16:00:00'),
  (8,  1, 2,  'DELIVERED',   348.90, '2024-03-01 10:00:00'),
  (9,  3, 4,  'CANCELLED',  1699.00, '2024-03-05 15:00:00'),
  (10, 2, 9,  'PAID',       2199.00, '2024-03-10 17:30:00');

-- =============================================================================
-- SUB-DOMAIN: ORDER — order_address (snapshot)
-- =============================================================================

INSERT INTO order_address (order_address_id, order_id, address_type, street, street_number, complement, neighborhood, city, state, postal_code) VALUES
  (1,  1,  'DELIVERY', 'Rua das Flores',       '123', 'Apto 42', 'Jardim Paulista', 'São Paulo',       'SP', '01452000'),
  (2,  2,  'DELIVERY', 'Rua do Catete',         '250',  NULL,     'Catete',          'Rio de Janeiro',  'RJ', '22220000'),
  (3,  3,  'DELIVERY', 'Av. Afonso Pena',       '500', 'Bloco B', 'Centro',          'Belo Horizonte',  'MG', '30130001'),
  (4,  4,  'DELIVERY', 'Rua XV de Novembro',     '88',  NULL,     'Centro',          'Curitiba',        'PR', '80020310'),
  (5,  5,  'DELIVERY', 'Av. Mauá',               '10', 'Casa',    'Navegantes',      'Porto Alegre',    'RS', '90220080'),
  (6,  6,  'DELIVERY', 'SQN 205 Bloco G',       '301',  NULL,     'Asa Norte',       'Brasília',        'DF', '70843070'),
  (7,  7,  'DELIVERY', 'Rua da Consolação',    '3000', 'Apto 11', 'Consolação',      'São Paulo',       'SP', '01416001'),
  (8,  8,  'DELIVERY', 'Av. Paulista',           '900', 'Sala 5', 'Bela Vista',      'São Paulo',       'SP', '01310100'),
  (9,  9,  'DELIVERY', 'Av. Afonso Pena',        '500', 'Bloco B','Centro',          'Belo Horizonte',  'MG', '30130001'),
  (10, 10, 'DELIVERY', 'Rua Voluntários Pátria', '780',  NULL,    'Botafogo',        'Rio de Janeiro',  'RJ', '22270010');

-- =============================================================================
-- SUB-DOMAIN: ORDER — order_item
-- =============================================================================

INSERT INTO order_item (order_id, variant_id, product_name, sku, quantity, unit_price, total_price) VALUES
  -- Pedido 1: Galaxy S24 + Teclado
  (1,  1,  'Samsung Galaxy S24 Ultra', 'SAM-S24U-256-BLK',  1, 6499.00, 6499.00),
  (1,  9,  'Teclado Redragon Kumara',  'RED-KUM-RGB-BLK',   1,  299.00,  299.00),
  -- Pedido 2: Dell Inspiron
  (2,  6,  'Dell Inspiron 15',         'DEL-INS15-512-SLV', 1, 4299.00, 4299.00),
  -- Pedido 3: Camisetas
  (3,  10, 'Camiseta Básica Masculina','HER-CM-P-WHT',       1,   49.90,   49.90),
  (3,  13, 'Camiseta Básica Feminina', 'HER-CF-P-WHT',       1,   44.90,   44.90),
  -- Pedido 4: iPhone 15 Pro 256GB
  (4,  4,  'Apple iPhone 15 Pro',      'APL-15PRO-256-WHT', 1, 7999.00, 7999.00),
  -- Pedido 5: Jogo de Cama + Furadeira
  (5,  18, 'Jogo de Cama Queen 300 Fios','BUD-JCQ-300-WHT', 1,  259.00,  259.00),
  (5,  19, 'Furadeira de Impacto 650W','BOS-GSB650-KIT',    1,  379.00,  379.00),
  -- Pedido 6: Nike Air Max 42
  (6,  16, 'Nike Air Max 270',         'NIK-AM270-42-BLK',  1,  549.00,  549.00),
  -- Pedido 7: Lenovo + Monitor
  (7,  7,  'Lenovo IdeaPad 3',         'LEN-IP3-256-GRY',   1, 2599.00, 2599.00),
  (7,  8,  'Monitor LG 27" 4K',        'LGM-27-4K-BLK',     1, 2199.00, 2199.00),
  -- Pedido 8: Teclado + Camiseta
  (8,  9,  'Teclado Redragon Kumara',  'RED-KUM-RGB-BLK',   1,  299.00,  299.00),
  (8,  11, 'Camiseta Básica Masculina','HER-CM-M-WHT',       1,   49.90,   49.90),
  -- Pedido 9: Moto G84 (cancelado)
  (9,  5,  'Motorola Moto G84',        'MOT-G84-256-GRA',   1, 1699.00, 1699.00),
  -- Pedido 10: Monitor LG
  (10, 8,  'Monitor LG 27" 4K',        'LGM-27-4K-BLK',     1, 2199.00, 2199.00);

-- =============================================================================
-- SUB-DOMAIN: ORDER — order_status_history
-- =============================================================================

INSERT INTO order_status_history (order_id, order_status, changed_at) VALUES
  -- Pedido 1: DELIVERED
  (1, 'CREATED',    '2024-01-15 09:45:00'),
  (1, 'PAID',       '2024-01-15 09:50:00'),
  (1, 'PROCESSING', '2024-01-15 10:00:00'),
  (1, 'SHIPPED',    '2024-01-16 08:00:00'),
  (1, 'DELIVERED',  '2024-01-22 14:30:00'),
  -- Pedido 2: SHIPPED
  (2, 'CREATED',    '2024-01-18 14:00:00'),
  (2, 'PAID',       '2024-01-18 14:10:00'),
  (2, 'PROCESSING', '2024-01-18 14:30:00'),
  (2, 'SHIPPED',    '2024-01-19 09:00:00'),
  -- Pedido 3: PROCESSING
  (3, 'CREATED',    '2024-01-20 11:30:00'),
  (3, 'PAID',       '2024-01-23 08:00:00'),
  (3, 'PROCESSING', '2024-01-23 09:00:00'),
  -- Pedido 4: PAID
  (4, 'CREATED',    '2024-02-01 19:00:00'),
  (4, 'PAID',       '2024-02-01 19:05:00'),
  -- Pedido 5: CREATED
  (5, 'CREATED',    '2024-02-10 08:20:00'),
  -- Pedido 6: DELIVERED
  (6, 'CREATED',    '2024-02-10 11:00:00'),
  (6, 'PAID',       '2024-02-10 11:02:00'),
  (6, 'PROCESSING', '2024-02-10 11:30:00'),
  (6, 'SHIPPED',    '2024-02-11 09:00:00'),
  (6, 'DELIVERED',  '2024-02-14 17:00:00'),
  -- Pedido 7: PROCESSING
  (7, 'CREATED',    '2024-02-15 16:00:00'),
  (7, 'PAID',       '2024-02-15 16:05:00'),
  (7, 'PROCESSING', '2024-02-15 17:00:00'),
  -- Pedido 8: DELIVERED
  (8, 'CREATED',    '2024-03-01 10:00:00'),
  (8, 'PAID',       '2024-03-01 10:02:00'),
  (8, 'PROCESSING', '2024-03-01 10:30:00'),
  (8, 'SHIPPED',    '2024-03-02 08:00:00'),
  (8, 'DELIVERED',  '2024-03-05 15:00:00'),
  -- Pedido 9: CANCELLED
  (9, 'CREATED',    '2024-03-05 15:00:00'),
  (9, 'CANCELLED',  '2024-03-05 16:00:00'),
  -- Pedido 10: PAID
  (10,'CREATED',    '2024-03-10 17:30:00'),
  (10,'PAID',       '2024-03-10 17:35:00');

-- =============================================================================
-- SUB-DOMAIN: FINANCE — payment
-- 1 payment por order; pedido 5 ainda PENDING
-- =============================================================================

INSERT INTO payment (payment_id, order_id, amount, payment_status, created_at) VALUES
  (1,  1,  6798.00, 'PAID',    '2024-01-15 09:50:00'),
  (2,  2,  4299.00, 'PAID',    '2024-01-18 14:10:00'),
  (3,  3,   94.80, 'PAID',    '2024-01-23 08:00:00'),
  (4,  4,  7999.00, 'PAID',    '2024-02-01 19:05:00'),
  (5,  5,   638.00, 'PENDING', '2024-02-10 08:20:00'),
  (6,  6,   549.00, 'PAID',    '2024-02-10 11:02:00'),
  (7,  7,  4798.00, 'PAID',    '2024-02-15 16:05:00'),
  (8,  8,   348.90, 'PAID',    '2024-03-01 10:02:00'),
  (9,  9,  1699.00, 'REFUNDED','2024-03-05 16:00:00'),
  (10, 10, 2199.00, 'PAID',    '2024-03-10 17:35:00');

-- =============================================================================
-- SUB-DOMAIN: FINANCE — charge
-- Pedido 9 tem charge FAILED (gerou o cancelamento) + charge PAID (reembolso)
-- =============================================================================

INSERT INTO charge (charge_id, payment_id, amount, payment_method, charge_status, gateway_ref, created_at) VALUES
  (1,  1,  6798.00, 'PIX',         'PAID',       'PIX-20240115-0001', '2024-01-15 09:50:00'),
  (2,  2,  4299.00, 'CREDIT_CARD', 'PAID',       'TXN-20240118-0002', '2024-01-18 14:10:00'),
  (3,  3,   94.80, 'BOLETO',      'PAID',       'BOL-20240123-0003', '2024-01-23 08:00:00'),
  (4,  4,  7999.00, 'CREDIT_CARD', 'PAID',       'TXN-20240201-0004', '2024-02-01 19:05:00'),
  (5,  5,   638.00, 'BOLETO',      'PENDING',     NULL,               '2024-02-10 08:20:00'),
  (6,  6,   549.00, 'PIX',         'PAID',       'PIX-20240210-0006', '2024-02-10 11:02:00'),
  (7,  7,  4798.00, 'CREDIT_CARD', 'PAID',       'TXN-20240215-0007', '2024-02-15 16:05:00'),
  (8,  8,   348.90, 'PIX',         'PAID',       'PIX-20240301-0008', '2024-03-01 10:02:00'),
  (9,  9,  1699.00, 'CREDIT_CARD', 'FAILED',     'TXN-20240305-0009', '2024-03-05 15:30:00'),
  (10, 10, 2199.00, 'CREDIT_CARD', 'PAID',       'TXN-20240310-0010', '2024-03-10 17:35:00');

-- =============================================================================
-- SUB-DOMAIN: FINANCE — charge_status_history
-- =============================================================================

INSERT INTO charge_status_history (charge_id, charge_status, changed_at) VALUES
  (1,  'PENDING',    '2024-01-15 09:50:00'),
  (1,  'PAID',       '2024-01-15 09:50:05'),
  (2,  'PENDING',    '2024-01-18 14:10:00'),
  (2,  'AUTHORIZED', '2024-01-18 14:10:03'),
  (2,  'PAID',       '2024-01-18 14:10:05'),
  (3,  'PENDING',    '2024-01-20 11:30:00'),
  (3,  'PAID',       '2024-01-23 08:00:00'),
  (4,  'PENDING',    '2024-02-01 19:05:00'),
  (4,  'AUTHORIZED', '2024-02-01 19:05:02'),
  (4,  'PAID',       '2024-02-01 19:05:04'),
  (5,  'PENDING',    '2024-02-10 08:20:00'),
  (6,  'PENDING',    '2024-02-10 11:02:00'),
  (6,  'PAID',       '2024-02-10 11:02:03'),
  (7,  'PENDING',    '2024-02-15 16:05:00'),
  (7,  'AUTHORIZED', '2024-02-15 16:05:02'),
  (7,  'PAID',       '2024-02-15 16:05:05'),
  (8,  'PENDING',    '2024-03-01 10:02:00'),
  (8,  'PAID',       '2024-03-01 10:02:04'),
  (9,  'PENDING',    '2024-03-05 15:30:00'),
  (9,  'FAILED',     '2024-03-05 15:30:10'),
  (10, 'PENDING',    '2024-03-10 17:35:00'),
  (10, 'AUTHORIZED', '2024-03-10 17:35:02'),
  (10, 'PAID',       '2024-03-10 17:35:04');

-- =============================================================================
-- SUB-DOMAIN: FINANCE — applied_fee
-- Taxa de plataforma + taxa de processamento por charge
-- =============================================================================

INSERT INTO applied_fee (charge_id, fee_rule_id, amount, created_at) VALUES
  -- Pedido 1: taxa padrão marketplace (12%) + Pix (0)
  (1,  1, 815.76, '2024-01-15 09:50:00'),
  (1,  7,   0.00, '2024-01-15 09:50:00'),
  -- Pedido 2: taxa padrão marketplace (12%) + cartão (2.5%)
  (2,  1, 515.88, '2024-01-18 14:10:00'),
  (2,  9, 107.48, '2024-01-18 14:10:00'),
  -- Pedido 3: taxa padrão marketplace (12%) + boleto (3.5%)
  (3,  1,  11.38, '2024-01-23 08:00:00'),
  (3,  8,   3.32, '2024-01-23 08:00:00'),
  -- Pedido 4: taxa padrão marketplace (12%) + cartão (2.5%)
  (4,  1, 959.88, '2024-02-01 19:05:00'),
  (4,  9, 199.98, '2024-02-01 19:05:00'),
  -- Pedido 6: taxa padrão marketplace (12%) + Pix (0)
  (6,  1,  65.88, '2024-02-10 11:02:00'),
  (6,  7,   0.00, '2024-02-10 11:02:00'),
  -- Pedido 7: taxa padrão marketplace (12%) + cartão (2.5%)
  (7,  1, 575.76, '2024-02-15 16:05:00'),
  (7,  9, 119.95, '2024-02-15 16:05:00'),
  -- Pedido 8: taxa padrão marketplace (12%) + Pix (0)
  (8,  1,  41.87, '2024-03-01 10:02:00'),
  (8,  7,   0.00, '2024-03-01 10:02:00'),
  -- Pedido 10: taxa padrão marketplace (12%) + cartão (2.5%)
  (10, 1, 263.88, '2024-03-10 17:35:00'),
  (10, 9,  54.98, '2024-03-10 17:35:00');

-- =============================================================================
-- SUB-DOMAIN: FINANCE — settlement
-- Pedidos pagos com cartão em parcelas; Pix e boleto em parcela única
-- =============================================================================

INSERT INTO settlement (charge_id, amount, installment, settlement_status, settled_at) VALUES
  -- Pedido 2: cartão 6x
  (2,   716.5, 1, 'SETTLED', '2024-02-18 00:00:00'),
  (2,   716.5, 2, 'SETTLED', '2024-03-18 00:00:00'),
  (2,   716.5, 3, 'SETTLED', '2024-04-18 00:00:00'),
  (2,   716.5, 4, 'PENDING',  NULL),
  (2,   716.5, 5, 'PENDING',  NULL),
  (2,   716.5, 6, 'PENDING',  NULL);

-- =============================================================================
-- SUB-DOMAIN: FINANCE — seller_balance
-- Um registro por seller; saldo reflete liquidações já processadas
-- =============================================================================

INSERT INTO seller_balance (seller_id, balance) VALUES
  (8,  12450.00),  -- TechStore: eletrônicos de alto valor
  (9,    380.00),  -- ModaExpress: margens menores
  (10,   520.00),  -- CasaLar
  (11,  1800.00),  -- MegaEletro
  (12,   410.00);  -- SportCia

-- =============================================================================
-- SUB-DOMAIN: FINANCE — payout
-- Transferências já realizadas e em andamento
-- =============================================================================

INSERT INTO payout (payout_id, seller_id, amount, payout_status, created_at) VALUES
  (1,  8,  5000.00, 'PAID',    '2024-01-31 00:00:00'),
  (2,  8,  4000.00, 'PAID',    '2024-02-29 00:00:00'),
  (3,  9,   200.00, 'PAID',    '2024-02-29 00:00:00'),
  (4,  10,  300.00, 'PAID',    '2024-02-29 00:00:00'),
  (5,  11, 1200.00, 'PAID',    '2024-02-29 00:00:00'),
  (6,  12,  300.00, 'PAID',    '2024-02-29 00:00:00'),
  (7,  8,  3000.00, 'PENDING', '2024-03-31 00:00:00'),
  (8,  9,   150.00, 'PENDING', '2024-03-31 00:00:00'),
  (9,  10,  200.00, 'PENDING', '2024-03-31 00:00:00'),
  (10, 11,  600.00, 'FAILED',  '2024-03-31 00:00:00');

-- =============================================================================
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
-- =============================================================================