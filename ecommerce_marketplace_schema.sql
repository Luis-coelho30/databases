SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS,  UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- =============================================================================
-- REDEFINIR CONFIGURAÇÕES
-- =============================================================================
DROP DATABASE IF EXISTS ecommerce_marketplace;
CREATE DATABASE ecommerce_marketplace
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE ecommerce_marketplace;

-- =============================================================================
-- CRIAÇÃO DAS TABELAS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Sub-Domain: User
-- Contains all user-related entities in this domain
-- -----------------------------------------------------------------------------

-- Table: User
-- Represents the super entity of all user types
CREATE TABLE user (
	user_id        INT UNSIGNED NOT NULL AUTO_INCREMENT,
    email          VARCHAR(100) NOT NULL,
    password_hash  VARCHAR(255) NOT NULL,
    phone_number   VARCHAR(20),
    created_at     TIMESTAMP 	NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP 	NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at 	   TIMESTAMP 	NULL,
    
    CONSTRAINT pk_user PRIMARY KEY (user_id),
    CONSTRAINT uq_user_email UNIQUE (email)
) ENGINE=InnoDB COMMENT='Users in the marketplace';

-- Table: Customer
-- Represents customers in the marketplace
CREATE TABLE customer (
    customer_id INT UNSIGNED 	NOT NULL,
    full_name   VARCHAR(100) 	NOT NULL,
    cpf         CHAR(11) 		NOT NULL,
    birth_date  DATE,
    created_at     TIMESTAMP 	NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP	NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at 	   TIMESTAMP 	NULL,
    
    CONSTRAINT pk_customer PRIMARY KEY (customer_id),
    CONSTRAINT fk_customer_user 
        FOREIGN KEY (customer_id) 
        REFERENCES user(user_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_customer_cpf UNIQUE (cpf)
) ENGINE=InnoDB COMMENT='Customers in the marketplace';

-- Table: seller
-- Represents Sellers in the marketplace
CREATE TABLE seller (
	seller_id       INT UNSIGNED 	NOT NULL,
    legal_name      VARCHAR(150) 	NOT NULL,
    trade_name      VARCHAR(100),
    cnpj            CHAR(14) 		NOT NULL,
    average_rating  DECIMAL(3,2) 	NOT NULL DEFAULT 0.00,
    created_at     TIMESTAMP 		NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP 		NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at 	   TIMESTAMP 		NULL,

    CONSTRAINT pk_seller PRIMARY KEY (seller_id),
    CONSTRAINT fk_seller_user 
        FOREIGN KEY (seller_id) 
        REFERENCES user(user_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_seller_cnpj UNIQUE (cnpj),
    CONSTRAINT ck_seller_rating CHECK (average_rating BETWEEN 0 AND 5)
) ENGINE=InnoDB COMMENT='Sellers in the marketplace';

-- Table: address
-- Billing and delivery addresses linked to a customer
CREATE TABLE address (
    address_id      INT UNSIGNED 	NOT NULL AUTO_INCREMENT,
    customer_id     INT UNSIGNED 	NOT NULL,
    address_type    ENUM(
						'DELIVERY',
						'BILLING',
						'BOTH'
						) 			NOT NULL DEFAULT 'BOTH',
    street          VARCHAR(200) 	NOT NULL,
    street_number   VARCHAR(10) 	NOT NULL,
    complement      VARCHAR(60),
    neighborhood    VARCHAR(80) 	NOT NULL,
    city            VARCHAR(80) 	NOT NULL,
    state           CHAR(2) 		NOT NULL,
    postal_code     CHAR(8) 		NOT NULL,
    country         CHAR(3) 		NOT NULL DEFAULT 'BRA',
    is_default      BOOLEAN 		NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP 		NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP 		NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at      TIMESTAMP       NULL,

    CONSTRAINT pk_address PRIMARY KEY (address_id),
    CONSTRAINT fk_address_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id)
        ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Billing and delivery addresses linked to a customer';

-- Table: seller_address
-- Physical addresses for sellers: store fronts, warehouses, and fiscal addresses.
CREATE TABLE seller_address (
    seller_address_id   INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    seller_id           INT UNSIGNED    NOT NULL,
    address_type        ENUM(
                            'STORE',
                            'WAREHOUSE',
                            'FISCAL'
                        )               NOT NULL DEFAULT 'STORE',
    street              VARCHAR(200)    NOT NULL,
    street_number       VARCHAR(10)     NOT NULL,
    complement          VARCHAR(60),
    neighborhood        VARCHAR(80)     NOT NULL,
    city                VARCHAR(80)     NOT NULL,
    state               CHAR(2)         NOT NULL,
    postal_code         CHAR(8)         NOT NULL,
    country             CHAR(3)         NOT NULL DEFAULT 'BRA',
    is_main             BOOLEAN         NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at      	TIMESTAMP       NULL,

    CONSTRAINT pk_seller_address PRIMARY KEY (seller_address_id),
    CONSTRAINT fk_seller_address_seller
        FOREIGN KEY (seller_id)
        REFERENCES seller(seller_id)
        ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Physical addresses for sellers (store, warehouse, fiscal)';

-- -----------------------------------------------------------------------------
-- Sub-Domain: Catalog
-- Contains all e-commerce calatog related entities in this domain
-- -----------------------------------------------------------------------------

-- Table: product
-- Products created by sellers
CREATE TABLE product (
    product_id     			INT UNSIGNED 	NOT NULL AUTO_INCREMENT,
    seller_id      			INT UNSIGNED 	NOT NULL,
    product_name            VARCHAR(150) 	NOT NULL,
    product_description     TEXT,
    is_active      			BOOLEAN 		NOT NULL DEFAULT TRUE,
    created_at     			TIMESTAMP 		NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     			TIMESTAMP 		NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	deleted_at 	   			TIMESTAMP 		NULL,

    CONSTRAINT pk_product PRIMARY KEY (product_id),
    CONSTRAINT fk_product_seller
        FOREIGN KEY (seller_id)
        REFERENCES seller(seller_id)
        ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Products created by sellers';

-- Table: product_variant
-- Variants of products created by sellers (allows for different colors or products specifications)
CREATE TABLE product_variant (
	variant_id       INT UNSIGNED 		NOT NULL AUTO_INCREMENT,
    product_id       INT UNSIGNED 		NOT NULL,
    sku              VARCHAR(50) 		NOT NULL,
    price            DECIMAL(10,2) 		NOT NULL,
    stock_quantity   INT UNSIGNED		NOT NULL DEFAULT 0,
    is_active        BOOLEAN 			NOT NULL DEFAULT TRUE,
    created_at       TIMESTAMP 			NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP 			NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at       TIMESTAMP       	NULL,

	CONSTRAINT uq_sku UNIQUE (sku), 
    CONSTRAINT ck_price CHECK (price >= 0),
    CONSTRAINT pk_variant PRIMARY KEY (variant_id),
    CONSTRAINT fk_variant_product
        FOREIGN KEY (product_id)
        REFERENCES product(product_id)
        ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Variants of products created by sellers (allows for different colors or products specifications)';

-- Table: category
-- Product categories (hierarchical, as a category may be a father to other categories) 
CREATE TABLE category (
    category_id   INT UNSIGNED 		NOT NULL AUTO_INCREMENT,
    category_name VARCHAR(100) 		NOT NULL,
    parent_id     INT UNSIGNED 		NULL,
    deleted_at      TIMESTAMP       NULL,

    CONSTRAINT pk_category PRIMARY KEY (category_id),
    CONSTRAINT fk_category_parent
        FOREIGN KEY (parent_id)
        REFERENCES category(category_id)
        ON DELETE SET NULL
) ENGINE=InnoDB COMMENT='Product categories (hierarchical)';

-- Table: product_category
-- Join table for product <-> category relationship (N:N)
CREATE TABLE product_category (
	category_id		INT UNSIGNED    NOT NULL,
    product_id		INT UNSIGNED    NOT NULL,
    
	CONSTRAINT pk_product_category PRIMARY KEY (product_id, category_id),
    CONSTRAINT fk_category          
		FOREIGN KEY (category_id)
        REFERENCES category (category_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_product           
		FOREIGN KEY (product_id)
        REFERENCES product (product_id) 
        ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Join table for product <-> category relationship (N:N)';

-- Tabela: product_image
-- Photos linked to a product
CREATE TABLE product_image (
    image_id     INT UNSIGNED 		NOT NULL AUTO_INCREMENT,
    variant_id   INT UNSIGNED 		NOT NULL,
    image_url    VARCHAR(255) 		NOT NULL,
    is_primary   BOOLEAN 			NOT NULL DEFAULT FALSE,
    created_at   TIMESTAMP 			NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_product_image PRIMARY KEY (image_id),
    CONSTRAINT fk_image_product
        FOREIGN KEY (variant_id)
        REFERENCES product_variant(variant_id)
        ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Photos linked to a product';

-- -----------------------------------------------------------------------------
-- Sub-Domain: Order
-- Handles order related objects
-- -----------------------------------------------------------------------------

-- Table: Orders
-- Represents an order made by a customer
CREATE TABLE orders (
    order_id        		INT UNSIGNED 	NOT NULL AUTO_INCREMENT,
    customer_id     		INT UNSIGNED 	NOT NULL,
	delivery_address_id   	INT UNSIGNED    NOT NULL,
	order_status    		ENUM(
								'CREATED',
								'PAID',
								'PROCESSING',
								'SHIPPED',
								'DELIVERED',
								'CANCELLED'
							) 				NOT NULL DEFAULT 'CREATED',
    total_amount    		DECIMAL(10,2) 	NOT NULL,
    created_at      		TIMESTAMP 		NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      		TIMESTAMP 		NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT pk_order PRIMARY KEY (order_id),
    CONSTRAINT fk_order_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id)
) ENGINE=InnoDB COMMENT='Represents an order made by a customer';

-- Table: order_item
-- Represents an item that is part of an order.
-- References product_variant to preserve exactly which variant
CREATE TABLE order_item (
    order_item_id   INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    order_id        INT UNSIGNED    NOT NULL,
    variant_id      INT UNSIGNED    NOT NULL,
    product_name    VARCHAR(150)    NOT NULL,  -- snapshot: name at purchase time
    sku             VARCHAR(50)     NOT NULL,  -- snapshot: SKU at purchase time
    quantity        INT             NOT NULL,
    unit_price      DECIMAL(10,2)   NOT NULL,  -- snapshot: price at purchase time
    total_price     DECIMAL(10,2)   NOT NULL,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
 
    CONSTRAINT pk_order_item    PRIMARY KEY (order_item_id),
    CONSTRAINT fk_item_variant
        FOREIGN KEY (variant_id)
        REFERENCES product_variant(variant_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_item_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE,
    CONSTRAINT ck_item_quantity  CHECK (quantity > 0),
    CONSTRAINT ck_item_price     CHECK (unit_price >= 0)
) ENGINE=InnoDB COMMENT='Items of an order references product_variant for full SKU/price snapshot';

-- Table: order_address
-- Represents an order address - Dereferences address table
CREATE TABLE order_address (
    order_address_id INT UNSIGNED 	NOT NULL AUTO_INCREMENT,
    order_id         INT UNSIGNED 	NOT NULL,
    address_type     ENUM(
						'DELIVERY',
						'BILLING'
					) 				NOT NULL,
    street           VARCHAR(200) 	NOT NULL,
    street_number    VARCHAR(10) 	NOT NULL,
    complement       VARCHAR(60),
    neighborhood     VARCHAR(80) 	NOT NULL,
    city             VARCHAR(80) 	NOT NULL,
    state            CHAR(2) 		NOT NULL,
    postal_code      CHAR(8) 		NOT NULL,
    country          CHAR(3) 		NOT NULL DEFAULT 'BRA',
    created_at       TIMESTAMP 		NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_order_address PRIMARY KEY (order_address_id),
    CONSTRAINT fk_order_address_order
		FOREIGN KEY (order_id) 
		REFERENCES orders(order_id)
		ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Represents an order address - Dereferences address table';

-- Table: order_status_history
-- Contains the history of changes in order status
CREATE TABLE order_status_history (
    history_id  	INT UNSIGNED 	NOT NULL AUTO_INCREMENT,
    order_id    	INT UNSIGNED 	NOT NULL,
    order_status    ENUM(
						'CREATED',
						'PAID',
						'PROCESSING',
						'SHIPPED',
						'DELIVERED',
						'CANCELLED'
					) 				NOT NULL DEFAULT 'CREATED',
    changed_at  	TIMESTAMP 		NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_order_history PRIMARY KEY (history_id),
    CONSTRAINT fk_history_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Contains the history of changes in order status';

-- -----------------------------------------------------------------------------
-- Sub-Domain: Finance
-- Handles payments, charges, settlements, fees and seller balances
-- -----------------------------------------------------------------------------

-- Table: Payment
-- Represents a payment linked to an order
CREATE TABLE payment (
    payment_id      INT UNSIGNED 		NOT NULL AUTO_INCREMENT,
    order_id        INT UNSIGNED 		NOT NULL,
    amount          DECIMAL(10,2) 		NOT NULL,
    payment_status  ENUM(
						'PENDING',
                        'PAID',
                        'FAILED',
                        'REFUNDED'
					) 					NOT NULL,
    created_at      TIMESTAMP 			NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP 			NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT pk_payment PRIMARY KEY (payment_id),
    CONSTRAINT fk_payment_order
		FOREIGN KEY (order_id)
		REFERENCES orders(order_id)
		ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Represents a payment linked to an order';

-- Table: Charge
-- Represents a charge attempt 
CREATE TABLE charge (
    charge_id       INT UNSIGNED 		NOT NULL AUTO_INCREMENT,
    payment_id      INT UNSIGNED 		NOT NULL,
    amount          DECIMAL(10,2) 		NOT NULL,
    payment_method  ENUM(
						'CREDIT_CARD',
                        'PIX',
                        'BOLETO'
					) 					NOT NULL,
    charge_status   ENUM(
						'PENDING',
                        'AUTHORIZED',
                        'PAID',
                        'FAILED'
					) 					NOT NULL,
    gateway_ref     VARCHAR(100),
    created_at      TIMESTAMP 			NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT pk_charge PRIMARY KEY (charge_id),
    CONSTRAINT fk_charge_payment
        FOREIGN KEY (payment_id)
        REFERENCES payment(payment_id)
        ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Represents a charge attempt';

-- Table: Charge
-- Contains the history of charge_attempts
CREATE TABLE charge_status_history (
    history_id 		  INT UNSIGNED 		NOT NULL AUTO_INCREMENT,
    charge_id  		  INT UNSIGNED 		NOT NULL,
    charge_status     ENUM(
							'PENDING',
							'AUTHORIZED',
							'PAID',
							'FAILED'
					  ) 				NOT NULL,
    changed_at 		  TIMESTAMP 		NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_charge_history PRIMARY KEY (history_id),
    CONSTRAINT fk_charge_history_charge 
		FOREIGN KEY (charge_id)
        REFERENCES charge(charge_id)
        ON DELETE CASCADE
)  ENGINE=InnoDB COMMENT='Contains the history of charge_attempts';

-- Table: Settlement
-- Represents actual money settlement (supports installments)
CREATE TABLE settlement (
    settlement_id   	INT UNSIGNED 		NOT NULL AUTO_INCREMENT,
    charge_id       	INT UNSIGNED 		NOT NULL,
    amount          	DECIMAL(10,2)		NOT NULL,
    installment     	INT NULL,
    settlement_status   ENUM(
							'PENDING',
							'SETTLED',
							'FAILED'
						) 					NOT NULL,
    settled_at      	TIMESTAMP 			NULL,

    CONSTRAINT pk_settlement PRIMARY KEY (settlement_id),
    CONSTRAINT fk_settlement_charge
        FOREIGN KEY (charge_id)
        REFERENCES charge(charge_id)
        ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Represents actual money settlement (supports installments)';

-- Table: Fee Rule
-- Defines marketplace fee strategies
CREATE TABLE fee_rule (
    fee_rule_id    INT UNSIGNED 		NOT NULL AUTO_INCREMENT,
    fee_name       VARCHAR(100) 		NOT NULL,
    fee_type       ENUM(
						'PERCENTAGE',
						'FIXED'
					) 					NOT NULL,
    fee_value      DECIMAL(10,2) 		NOT NULL,
    min_amount     DECIMAL(10,2),
    max_amount     DECIMAL(10,2),
    is_active      BOOLEAN 				NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMP 			NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_fee_rule PRIMARY KEY (fee_rule_id)
) ENGINE=InnoDB COMMENT='Defines marketplace fee strategies';

-- Table: Applied Fee
-- Snapshot of fee applied at charge time
CREATE TABLE applied_fee (
    applied_fee_id  INT UNSIGNED 		NOT NULL AUTO_INCREMENT,
    charge_id       INT UNSIGNED 		NOT NULL,
    fee_rule_id     INT UNSIGNED 		NOT NULL,
    amount          DECIMAL(10,2) 		NOT NULL,
    created_at      TIMESTAMP 			NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_applied_fee PRIMARY KEY (applied_fee_id),
    CONSTRAINT fk_applied_fee_charge
        FOREIGN KEY (charge_id)
        REFERENCES charge(charge_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_applied_fee_rule
        FOREIGN KEY (fee_rule_id)
        REFERENCES fee_rule(fee_rule_id)
) ENGINE=InnoDB COMMENT='Snapshot of fee applied at charge time';

-- Table: Seller Balance
-- Tracks current balance available to seller
CREATE TABLE seller_balance (
    seller_id   INT UNSIGNED 		NOT NULL,
    balance     DECIMAL(10,2) 		NOT NULL DEFAULT 0.00,
    updated_at  TIMESTAMP 			NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

	CONSTRAINT ck_balance CHECK(balance >= 0),
    CONSTRAINT pk_seller_balance PRIMARY KEY (seller_id),
    CONSTRAINT fk_balance_seller
        FOREIGN KEY (seller_id)
        REFERENCES seller(seller_id)
        ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Tracks current balance available to seller';

-- Table: Payout
-- Represents money transferred to seller
CREATE TABLE payout (
    payout_id    	INT UNSIGNED 	NOT NULL AUTO_INCREMENT,
    seller_id    	INT UNSIGNED 	NOT NULL,
    amount       	DECIMAL(10,2) 	NOT NULL,
    payout_status   ENUM(
						'PENDING',
						'PAID',
						'FAILED'
					) 				NOT NULL,
    created_at   	TIMESTAMP 		NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_payout PRIMARY KEY (payout_id),
    CONSTRAINT fk_payout_seller
        FOREIGN KEY (seller_id)
        REFERENCES seller(seller_id)
) ENGINE=InnoDB COMMENT='Represents money transferred to seller';

-- =============================================================================
-- ÍNDICES 
-- =============================================================================

-- Charge
CREATE INDEX idx_charge_payment ON charge(payment_id);

-- Settlement
CREATE INDEX idx_settlement_charge ON settlement(charge_id);

-- Applied_fee
CREATE INDEX idx_applied_fee_charge ON applied_fee(charge_id);

-- Order
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_orders_created_at ON orders(created_at);

-- Product
CREATE INDEX idx_product_seller ON product(seller_id);
CREATE INDEX idx_product_active ON product(is_active);

-- Product_variant
CREATE INDEX idx_variant_product ON product_variant(product_id);

-- Order_item
CREATE INDEX idx_order_item_order ON order_item(order_id);
CREATE INDEX idx_order_item_variant ON order_item(variant_id);

-- Payment
CREATE INDEX idx_payment_order ON payment(order_id);

-- Address
CREATE INDEX idx_address_customer       ON address(customer_id);
CREATE INDEX idx_seller_address_seller  ON seller_address(seller_id);
CREATE INDEX idx_orders_delivery_addr   ON orders(delivery_address_id);

-- =============================================================================
-- RESTAURAR CONFIGURAÇÕES
-- =============================================================================
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;