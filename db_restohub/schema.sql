PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

-- 1. Пользователи
CREATE TABLE users (
    user_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name   TEXT    NOT NULL,
    email       TEXT    NOT NULL UNIQUE,
    phone       TEXT,
    role        TEXT    NOT NULL CHECK (role IN ('customer','courier','admin')),
    status      TEXT    NOT NULL DEFAULT 'active'
                        CHECK (status IN ('active','blocked'))
);

-- 2. Адреса
CREATE TABLE addresses (
    address_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id      INTEGER NOT NULL,
    address_text TEXT    NOT NULL,
    is_default   INTEGER NOT NULL DEFAULT 0, -- 0/1 как bool
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 3. Рестораны
CREATE TABLE restaurants (
    restaurant_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    name               TEXT    NOT NULL,
    cuisine_type       TEXT,
    address            TEXT,
    rating             REAL    NOT NULL DEFAULT 0.0,
    partnership_status TEXT    NOT NULL DEFAULT 'active'
                               CHECK (partnership_status IN ('active','paused','terminated'))
);

-- 4. Блюда
CREATE TABLE dishes (
    dish_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    restaurant_id INTEGER NOT NULL,
    name          TEXT    NOT NULL,
    category      TEXT,
    price         REAL    NOT NULL,
    is_available  INTEGER NOT NULL DEFAULT 1, -- 1 = доступно
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

-- 5. Корзины
CREATE TABLE carts (
    cart_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id   INTEGER NOT NULL,
    status    TEXT    NOT NULL DEFAULT 'active'
                      CHECK (status IN ('active','abandoned')),
    subtotal  REAL    NOT NULL DEFAULT 0.0,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 6. Позиции в корзине
CREATE TABLE cart_items (
    cart_item_id INTEGER PRIMARY KEY AUTOINCREMENT,
    cart_id      INTEGER NOT NULL,
    dish_id      INTEGER NOT NULL,
    quantity     INTEGER NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (cart_id) REFERENCES carts(cart_id),
    FOREIGN KEY (dish_id) REFERENCES dishes(dish_id)
);

-- 7. Заказы
CREATE TABLE orders (
    order_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    order_number   TEXT    NOT NULL UNIQUE,
    user_id        INTEGER NOT NULL,
    restaurant_id  INTEGER NOT NULL,
    address_id     INTEGER,
    order_type     TEXT    NOT NULL CHECK (order_type IN ('delivery','pickup')),
    status         TEXT    NOT NULL,
    total_amount   REAL    NOT NULL DEFAULT 0.0,
    payment_status TEXT    NOT NULL DEFAULT 'unpaid'
                           CHECK (payment_status IN ('unpaid','paid','refunded')),
    risk_score     REAL    NOT NULL DEFAULT 0.0,
    created_at     TEXT    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)       REFERENCES users(user_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    FOREIGN KEY (address_id)    REFERENCES addresses(address_id)
);

-- 8. Позиции заказа
CREATE TABLE order_items (
    order_item_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id      INTEGER NOT NULL,
    dish_id       INTEGER NOT NULL,
    quantity      INTEGER NOT NULL CHECK (quantity > 0),
    item_price    REAL    NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (dish_id)  REFERENCES dishes(dish_id)
);

-- 9. Доставка
CREATE TABLE deliveries (
    delivery_id  INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id     INTEGER NOT NULL UNIQUE, -- одна доставка на заказ
    courier_id   INTEGER NOT NULL,        -- users.role = 'courier'
    status       TEXT    NOT NULL,
    eta_planned  TEXT,
    eta_actual   TEXT,
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (courier_id) REFERENCES users(user_id)
);

-- 10. Платежи
CREATE TABLE payments (
    payment_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id     INTEGER NOT NULL,
    provider     TEXT,
    method_type  TEXT,
    amount       REAL    NOT NULL,
    status       TEXT    NOT NULL,
    paid_at      TEXT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Несколько полезных индексов
CREATE INDEX idx_addresses_user ON addresses(user_id);
CREATE INDEX idx_dishes_restaurant ON dishes(restaurant_id);
CREATE INDEX idx_carts_user ON carts(user_id);
CREATE INDEX idx_cart_items_cart ON cart_items(cart_id);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_restaurant ON orders(restaurant_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_deliveries_courier ON deliveries(courier_id);
CREATE INDEX idx_payments_order ON payments(order_id);

COMMIT;
