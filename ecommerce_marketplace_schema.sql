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
	user_id        INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the user',
    email          VARCHAR(100) NOT NULL                COMMENT 'Unique email address for authentication',
    password_hash  VARCHAR(255) NOT NULL                COMMENT 'Secure hash of the user password',
    phone_number   VARCHAR(20)                          COMMENT 'Contact phone number',
    created_at     TIMESTAMP 	NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at     TIMESTAMP 	NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at 	   TIMESTAMP 	NULL                    COMMENT 'Timestamp for soft delete',
    
    CONSTRAINT pk_user PRIMARY KEY (user_id),
    CONSTRAINT uq_user_email UNIQUE (email)
) ENGINE=InnoDB COMMENT='Users in the marketplace';

-- Table: Customer
-- Represents customers in the marketplace
CREATE TABLE customer (
    customer_id    INT UNSIGNED 	NOT NULL   COMMENT 'FK to user.user_id',
    full_name      VARCHAR(100)     NOT NULL   COMMENT 'Customer full legal name',
    cpf            CHAR(11) 		NOT NULL   COMMENT 'Brazilian Individual Taxpayer Registry ID (numbers only)',
    birth_date     DATE                        COMMENT 'Date of birth for age validation',
    created_at     TIMESTAMP 	    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at     TIMESTAMP	    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at 	   TIMESTAMP 	    NULL       COMMENT 'Timestamp for soft delete',
    
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
	seller_id       INT UNSIGNED 	NOT NULL   COMMENT 'FK to user.user_id',
    legal_name      VARCHAR(150) 	NOT NULL   COMMENT 'Official registered business name',
    trade_name      VARCHAR(100)               COMMENT 'Public-facing store name',
    cnpj            CHAR(14) 		NOT NULL   COMMENT 'Brazilian Corporate Taxpayer Registry ID',
    average_rating  DECIMAL(3,2) 	NOT NULL DEFAULT 0.00  COMMENT 'Aggregated rating from 0.00 to 5.00',
    created_at     TIMESTAMP 		NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at     TIMESTAMP 		NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at 	   TIMESTAMP 		NULL       COMMENT 'Timestamp for soft delete',

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
    address_id      INT UNSIGNED 	NOT NULL AUTO_INCREMENT    COMMENT 'Unique identifier for the address',
    customer_id     INT UNSIGNED 	NOT NULL                   COMMENT 'FK to the customer this address belongs to',
    address_type    ENUM(                                       
						'DELIVERY',
						'BILLING',
						'BOTH'
						) 			NOT NULL DEFAULT 'BOTH'    COMMENT 'Type of address: delivery, billing or both',
    street          VARCHAR(200) 	NOT NULL                   COMMENT 'Street name of the address',
    street_number   VARCHAR(10) 	NOT NULL                   COMMENT 'Street number of the address',
    complement      VARCHAR(60)                                COMMENT 'Additional address information (apartment, suite, etc.)',
    neighborhood    VARCHAR(80) 	NOT NULL                   COMMENT 'Neighborhood of the address',
    city            VARCHAR(80) 	NOT NULL                   COMMENT 'City of the address',
    state           CHAR(2) 		NOT NULL                   COMMENT 'State of the address',
    postal_code     CHAR(8) 		NOT NULL                   COMMENT 'Postal code of the address',
    country         CHAR(3) 		NOT NULL DEFAULT 'BRA'     COMMENT 'Country of the address',
    is_default      BOOLEAN 		NOT NULL DEFAULT FALSE     COMMENT 'Indicates if this is the default address for the customer',
    created_at      TIMESTAMP 		NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at      TIMESTAMP 		NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at      TIMESTAMP       NULL                       COMMENT 'Timestamp for soft delete',

    CONSTRAINT pk_address PRIMARY KEY (address_id),
    CONSTRAINT fk_address_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id)
        ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Billing and delivery addresses linked to a customer';

-- Table: seller_address
-- Physical addresses for sellers: store fronts, warehouses, and fiscal addresses.
CREATE TABLE seller_address (
    seller_address_id   INT UNSIGNED    NOT NULL AUTO_INCREMENT    COMMENT 'Unique identifier for the seller address',
    seller_id           INT UNSIGNED    NOT NULL                   COMMENT 'FK to the seller this address belongs to',
    address_type        ENUM(
                            'STORE',
                            'WAREHOUSE',
                            'FISCAL'
                        )               NOT NULL DEFAULT 'STORE'   COMMENT 'Type of address: store front, warehouse, or fiscal',
    street              VARCHAR(200)    NOT NULL                   COMMENT 'Street name of the address',
    street_number       VARCHAR(10)     NOT NULL                   COMMENT 'Street number of the address',
    complement          VARCHAR(60)                                COMMENT 'Additional address information (apartment, suite, etc.)',
    neighborhood        VARCHAR(80)     NOT NULL                   COMMENT 'Neighborhood of the address',
    city                VARCHAR(80)     NOT NULL                   COMMENT 'City of the address',
    state               CHAR(2)         NOT NULL                   COMMENT 'State of the address',
    postal_code         CHAR(8)         NOT NULL                   COMMENT 'Postal code of the address',
    country             CHAR(3)         NOT NULL DEFAULT 'BRA'     COMMENT 'Country of the address',
    is_main             BOOLEAN         NOT NULL DEFAULT FALSE     COMMENT 'Indicates if this is the main address for the seller',
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at      	TIMESTAMP       NULL                       COMMENT 'Timestamp for soft delete',   

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
    product_id     			INT UNSIGNED 	NOT NULL AUTO_INCREMENT    COMMENT 'Unique identifier for the product',
    seller_id      			INT UNSIGNED 	NOT NULL                   COMMENT 'FK to the seller who created the product',
    product_name            VARCHAR(150) 	NOT NULL                   COMMENT 'Name of the product',
    product_description     TEXT                                       COMMENT 'Description of the product',
    is_active      			BOOLEAN 		NOT NULL DEFAULT TRUE      COMMENT 'Indicates if the product is active',
    created_at     			TIMESTAMP 		NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at     			TIMESTAMP 		NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
	deleted_at 	   			TIMESTAMP 		NULL                       COMMENT 'Timestamp for soft delete',   

    CONSTRAINT pk_product PRIMARY KEY (product_id),
    CONSTRAINT fk_product_seller
        FOREIGN KEY (seller_id)
        REFERENCES seller(seller_id)
        ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Products created by sellers';

-- Table: product_variant
-- Variants of products created by sellers (allows for different colors or products specifications)
CREATE TABLE product_variant (
	variant_id       INT UNSIGNED 		NOT NULL AUTO_INCREMENT    COMMENT 'Unique identifier for the product variant',
    product_id       INT UNSIGNED 		NOT NULL                   COMMENT 'FK to the product this variant belongs to',
    sku              VARCHAR(50) 		NOT NULL                   COMMENT 'Stock Keeping Unit for the variant',
    price            DECIMAL(10,2) 		NOT NULL                   COMMENT 'Price of the variant',
    stock_quantity   INT UNSIGNED		NOT NULL DEFAULT 0         COMMENT 'Available quantity of the variant',
    is_active        BOOLEAN 			NOT NULL DEFAULT TRUE      COMMENT 'Indicates if the variant is active',
    created_at       TIMESTAMP 			NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at       TIMESTAMP 			NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at       TIMESTAMP       	NULL                       COMMENT 'Timestamp for soft delete',

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
    category_id   INT UNSIGNED 		NOT NULL AUTO_INCREMENT    COMMENT 'Unique identifier for the category',
    category_name VARCHAR(100) 		NOT NULL                   COMMENT 'Name of the category',
    parent_id     INT UNSIGNED 		NULL                       COMMENT 'Self-referencing FK to parent category (NULL for top-level categories)',
    deleted_at      TIMESTAMP       NULL                       COMMENT 'Timestamp for soft delete',

    CONSTRAINT pk_category PRIMARY KEY (category_id),
    CONSTRAINT fk_category_parent
        FOREIGN KEY (parent_id)
        REFERENCES category(category_id)
        ON DELETE SET NULL
) ENGINE=InnoDB COMMENT='Product categories (hierarchical)';

-- Table: product_category
-- Join table for product <-> category relationship (N:N)
CREATE TABLE product_category (
	category_id		INT UNSIGNED    NOT NULL           COMMENT 'FK to category.category_id',
    product_id		INT UNSIGNED    NOT NULL           COMMENT 'FK to product.product_id',
    
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
    image_id     INT UNSIGNED 		NOT NULL AUTO_INCREMENT    COMMENT 'Unique identifier for the product image',
    variant_id   INT UNSIGNED 		NOT NULL                   COMMENT 'FK to the product variant this image belongs to',
    image_url    VARCHAR(255) 		NOT NULL                   COMMENT 'URL of the product image',
    is_primary   BOOLEAN 			NOT NULL DEFAULT FALSE     COMMENT 'Indicates if this is the primary image for the variant',
    created_at   TIMESTAMP 			NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',

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
    order_id        		INT UNSIGNED 	NOT NULL AUTO_INCREMENT    COMMENT 'Unique identifier for the order',
    customer_id     		INT UNSIGNED 	NOT NULL                   COMMENT 'FK to the customer who made the order',
	delivery_address_id   	INT UNSIGNED    NOT NULL                   COMMENT 'FK to the delivery address for the order (address_id)',
	order_status    		ENUM(
								'CREATED',
								'PAID',
								'PROCESSING',
								'SHIPPED',
								'DELIVERED',
								'CANCELLED'
							) 				NOT NULL DEFAULT 'CREATED' COMMENT 'Current status of the order',
    total_amount    		DECIMAL(10,2) 	NOT NULL                   COMMENT 'Total amount of the order (calculated at checkout)',
    created_at      		TIMESTAMP 		NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at      		TIMESTAMP 		NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',

    CONSTRAINT pk_order PRIMARY KEY (order_id),
    CONSTRAINT fk_order_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id)
) ENGINE=InnoDB COMMENT='Represents an order made by a customer';

-- Table: order_item
-- Represents an item that is part of an order.
-- References product_variant to preserve exactly which variant
CREATE TABLE order_item (
    order_item_id   INT UNSIGNED    NOT NULL AUTO_INCREMENT    COMMENT 'Unique identifier for the order item',
    order_id        INT UNSIGNED    NOT NULL                   COMMENT 'FK to the order this item belongs to',
    variant_id      INT UNSIGNED    NOT NULL                   COMMENT 'FK to the product variant being purchased (snapshot of variant at purchase time)',
    product_name    VARCHAR(150)    NOT NULL                   COMMENT 'snapshot: product name at purchase time',
    sku             VARCHAR(50)     NOT NULL                   COMMENT 'snapshot: SKU of the variant at purchase time',
    quantity        INT             NOT NULL                   COMMENT 'Quantity of this variant being purchased',
    unit_price      DECIMAL(10,2)   NOT NULL                   COMMENT 'snapshot: unit price of the variant at purchase time',
    total_price     DECIMAL(10,2)   NOT NULL                   COMMENT 'snapshot: total price for this item (quantity * unit_price) at purchase time',
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',

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
    order_address_id INT UNSIGNED 	NOT NULL AUTO_INCREMENT    COMMENT 'Unique identifier for the order address',
    order_id         INT UNSIGNED 	NOT NULL                   COMMENT 'FK to the order this address belongs to',
    address_type     ENUM(
						'DELIVERY',
						'BILLING'
					) 				NOT NULL                   COMMENT 'Type of the address (delivery or billing)',
    street           VARCHAR(200) 	NOT NULL                   COMMENT 'Street name of the address',
    street_number    VARCHAR(10) 	NOT NULL                   COMMENT 'Street number of the address',
    complement       VARCHAR(60)                               COMMENT 'Additional address information (apartment, suite, etc.)',
    neighborhood     VARCHAR(80) 	NOT NULL                   COMMENT 'Neighborhood of the address',
    city             VARCHAR(80) 	NOT NULL                   COMMENT 'City of the address',
    state            CHAR(2) 		NOT NULL                   COMMENT 'State of the address',
    postal_code      CHAR(8) 		NOT NULL                   COMMENT 'Postal code of the address',
    country          CHAR(3) 		NOT NULL DEFAULT 'BRA'     COMMENT 'Country of the address',
    created_at       TIMESTAMP 		NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',

    CONSTRAINT pk_order_address PRIMARY KEY (order_address_id),
    CONSTRAINT fk_order_address_order
		FOREIGN KEY (order_id) 
		REFERENCES orders(order_id)
		ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Represents an order address - Dereferences address table';

-- Table: order_status_history
-- Contains the history of changes in order status
CREATE TABLE order_status_history (
    history_id  	INT UNSIGNED 	NOT NULL AUTO_INCREMENT    COMMENT 'Unique identifier for the order status history record',
    order_id    	INT UNSIGNED 	NOT NULL                   COMMENT 'FK to the order this status change belongs to',
    order_status    ENUM(
						'CREATED',
						'PAID',
						'PROCESSING',
						'SHIPPED',
						'DELIVERED',
						'CANCELLED'
					) 				NOT NULL DEFAULT 'CREATED' COMMENT 'Order status at the time of the change',
    changed_at  	TIMESTAMP 		NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the order status was changed',

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
    payment_id      INT UNSIGNED 		NOT NULL AUTO_INCREMENT    COMMENT 'Unique identifier for the payment',
    order_id        INT UNSIGNED 		NOT NULL                   COMMENT 'FK to the order this payment belongs to',
    amount          DECIMAL(10,2) 		NOT NULL                   COMMENT 'Payment amount',
    payment_status  ENUM(
						'PENDING',
                        'PAID',
                        'FAILED',
                        'REFUNDED'
					) 					NOT NULL                   COMMENT 'Current status of the payment',
    created_at      TIMESTAMP 			NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at      TIMESTAMP 			NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',

    CONSTRAINT pk_payment PRIMARY KEY (payment_id),
    CONSTRAINT fk_payment_order
		FOREIGN KEY (order_id)
		REFERENCES orders(order_id)
		ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Represents a payment linked to an order';

-- Table: Charge
-- Represents a charge attempt 
CREATE TABLE charge (
    charge_id       INT UNSIGNED 		NOT NULL AUTO_INCREMENT    COMMENT 'Unique identifier for the charge attempt',
    payment_id      INT UNSIGNED 		NOT NULL                   COMMENT 'FK to the payment this charge attempt belongs to',
    amount          DECIMAL(10,2) 		NOT NULL                   COMMENT 'Amount attempted to charge (may be equal or less than payment amount in case of installments)',
    payment_method  ENUM(
						'CREDIT_CARD',
                        'PIX',
                        'BOLETO'
					) 					NOT NULL                   COMMENT 'Payment method used for the charge attempt',  
    charge_status   ENUM(
						'PENDING',
                        'AUTHORIZED',
                        'PAID',
                        'FAILED'
					) 					NOT NULL                   COMMENT 'Current status of the charge attempt',
    gateway_ref     VARCHAR(100)                                   COMMENT 'Reference from the payment gateway for this charge attempt',
    created_at      TIMESTAMP 			NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',

    CONSTRAINT pk_charge PRIMARY KEY (charge_id),
    CONSTRAINT fk_charge_payment
        FOREIGN KEY (payment_id)
        REFERENCES payment(payment_id)
        ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Represents a charge attempt';

-- Table: Charge
-- Contains the history of charge_attempts
CREATE TABLE charge_status_history (
    history_id 		  INT UNSIGNED 		NOT NULL AUTO_INCREMENT    COMMENT 'Unique identifier for the charge status history record',
    charge_id  		  INT UNSIGNED 		NOT NULL                   COMMENT 'FK to the charge this status change belongs to',
    charge_status     ENUM(
							'PENDING',
							'AUTHORIZED',
							'PAID',
							'FAILED'
					  ) 				NOT NULL                   COMMENT 'Charge status at the time of the change', 
    changed_at 		  TIMESTAMP 		NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the charge status was changed',

    CONSTRAINT pk_charge_history PRIMARY KEY (history_id),
    CONSTRAINT fk_charge_history_charge 
		FOREIGN KEY (charge_id)
        REFERENCES charge(charge_id)
        ON DELETE CASCADE
)  ENGINE=InnoDB COMMENT='Contains the history of charge_attempts';

-- Table: Settlement
-- Represents actual money settlement (supports installments)
CREATE TABLE settlement (
    settlement_id   	INT UNSIGNED 		NOT NULL AUTO_INCREMENT    COMMENT 'Unique identifier for the settlement',
    charge_id       	INT UNSIGNED 		NOT NULL                   COMMENT 'FK to the charge this settlement belongs to',
    amount          	DECIMAL(10,2)		NOT NULL                   COMMENT 'Amount settled (may be equal or less than charge amount in case of installments)',
    installment     	INT NULL,
    settlement_status   ENUM(
							'PENDING',
							'SETTLED',
							'FAILED'
						) 					NOT NULL                   COMMENT 'Current status of the settlement',
    settled_at      	TIMESTAMP 			NULL                       COMMENT 'Timestamp when the settlement was completed (NULL if pending)',

    CONSTRAINT pk_settlement PRIMARY KEY (settlement_id),
    CONSTRAINT fk_settlement_charge
        FOREIGN KEY (charge_id)
        REFERENCES charge(charge_id)
        ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Represents actual money settlement (supports installments)';

-- Table: Fee Rule
-- Defines marketplace fee strategies
CREATE TABLE fee_rule (
    fee_rule_id    INT UNSIGNED 		NOT NULL AUTO_INCREMENT    COMMENT 'Unique identifier for the fee rule',
    fee_name       VARCHAR(100) 		NOT NULL                   COMMENT 'Name of the fee rule',
    fee_type       ENUM(
						'PERCENTAGE',
						'FIXED'
					) 					NOT NULL                   COMMENT 'Type of fee: percentage of the order amount or fixed value',
    fee_value      DECIMAL(10,2) 		NOT NULL                   COMMENT 'Value of the fee (percentage value or fixed amount depending on fee_type)',
    min_amount     DECIMAL(10,2)                                   COMMENT 'Minimum fee amount (used for percentage fees to ensure a minimum charge)',
    max_amount     DECIMAL(10,2)                                   COMMENT 'Maximum fee amount (used for percentage fees to limit the maximum charge)',
    is_active      BOOLEAN 				NOT NULL DEFAULT TRUE      COMMENT 'Indicates if the fee rule is active and should be applied to new orders',
    created_at     TIMESTAMP 			NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',

    CONSTRAINT pk_fee_rule PRIMARY KEY (fee_rule_id)
) ENGINE=InnoDB COMMENT='Defines marketplace fee strategies';

-- Table: Applied Fee
-- Snapshot of fee applied at charge time
CREATE TABLE applied_fee (
    applied_fee_id  INT UNSIGNED 		NOT NULL AUTO_INCREMENT    COMMENT 'Unique identifier for the applied fee record',
    charge_id       INT UNSIGNED 		NOT NULL                   COMMENT 'FK to the charge this fee was applied to',
    fee_rule_id     INT UNSIGNED 		NOT NULL                   COMMENT 'FK to the fee rule that was applied',
    amount          DECIMAL(10,2) 		NOT NULL                   COMMENT 'Amount of the fee applied (calculated at charge time based on the fee rule and order amount)',
    created_at      TIMESTAMP 			NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',

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
    seller_id   INT UNSIGNED 		NOT NULL               COMMENT 'FK to the seller this balance belongs to',
    balance     DECIMAL(10,2) 		NOT NULL DEFAULT 0.00  COMMENT 'Current balance available to the seller',
    updated_at  TIMESTAMP 			NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp of the last balance update',

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
    payout_id    	INT UNSIGNED 	NOT NULL AUTO_INCREMENT    COMMENT 'Unique identifier for the payout',
    seller_id    	INT UNSIGNED 	NOT NULL                   COMMENT 'FK to the seller receiving the payout',
    amount       	DECIMAL(10,2) 	NOT NULL                   COMMENT 'Amount of the payout',
    payout_status   ENUM(
						'PENDING',
						'PAID',
						'FAILED'
					) 				NOT NULL                   COMMENT 'Current status of the payout',
    created_at   	TIMESTAMP 		NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',

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