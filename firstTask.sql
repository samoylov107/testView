CREATE DATABASE TestTasks

USE TestTasks

CREATE SCHEMA firstTask /* Необходимо:
Посчитать сумму транзакций клиента в рублях за месяц */

CREATE TABLE TestTasks.firstTask.[TRANSACTION] (CUST_ID INT, TRANSACTION_DT DATETIME2, CURRENCY_ID CHAR (3), TRANSACTION_AMT MONEY) 
CREATE TABLE TestTasks.firstTask.CURRENCY_RATE (CURRENCY_ID CHAR (3), EXCH_RATE MONEY, VALID_FROM DATETIME2, VALID_TO DATETIME2)

INSERT INTO TestTasks.firstTask.[TRANSACTION] (CUST_ID, TRANSACTION_DT, CURRENCY_ID, TRANSACTION_AMT)
VALUES (1, '20210101', 'RUR', 1000),
       (1, '20210102', 'EUR',  100),
	   (1, '20210103', 'EUR',  100),
	   (1, '20210104', 'USD',   50),
	   (2, '20210101', 'USD',  150),
	   (2, '20210102', 'USD',  200),
	   (2, '20210104', 'USD',   50),
	   (3, '20210101', 'RUR', 2000),
	   (3, '20210104', 'RUR', 5000)

INSERT INTO TestTasks.firstTask.CURRENCY_RATE (CURRENCY_ID, EXCH_RATE, VALID_FROM, VALID_TO)
VALUES ('RUR',  1, '19000101', '40000101'),
       ('EUR', 90, '20210101', '20210103'),
	   ('EUR', 95, '20210103', '40000101'),
	   ('USD', 70, '20210101', '20210102'),
	   ('USD', 75, '20210102', '20210104'),
	   ('USD', 70, '20210104', '40000101')

SELECT YEAR(TRANSACTION_DT) AS Year, MONTH(TRANSACTION_DT) AS Month, CUST_ID, SUM(totalRUR) AS 'Сумма в ₽'
  FROM 
(SELECT t.CUST_ID, cr.CURRENCY_ID, t.TRANSACTION_DT, t.TRANSACTION_AMT * MAX(cr.EXCH_RATE) AS totalRUR
   FROM TestTasks.firstTask.[TRANSACTION] AS t 
   JOIN TestTasks.firstTask.CURRENCY_RATE AS cr ON t.CURRENCY_ID = cr.CURRENCY_ID
                                              AND t.TRANSACTION_DT BETWEEN cr.VALID_FROM AND cr.VALID_TO
  GROUP BY t.CUST_ID, cr.CURRENCY_ID, t.TRANSACTION_AMT, t.TRANSACTION_DT) z1
 GROUP BY YEAR(TRANSACTION_DT), MONTH(TRANSACTION_DT), CUST_ID

/* Т.к. при соединении "t.TRANSACTION_DT BETWEEN cr.VALID_FROM AND cr.VALID_TO" может заджойниться сразу несколько курсов на 1 дату, 
   сперва получаю максимальный курс на каждую дату и только затем ежемесячную сумму рассходов */