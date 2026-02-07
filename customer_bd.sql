select * from customer limit 20
--Q1. ¿Cuál es el ingreso total generado por clientes hombres vs. mujeres?
select gender, sum(purchase_amount) as total_ingresos from customer group by gender
--Q2. ¿Qué clientes usaron un descuento pero aun así gastaron más que el monto promedio de compra?
select customer_id,purchase_amount from customer 
where discount_applied = 'Yes' and purchase_amount >= (select avg(purchase_amount) from customer)
--Q3. ¿Cuáles son los 5 productos con el promedio de calificación de reseñas más alto?
select item_purchased,round(avg(review_rating::numeric),2) as total_review from customer
group by item_purchased
order by total_review desc
limit 5
--Q4. Compara los montos promedio de compra entre el envío estándar (Standard) y el envío exprés (Express).
SELECT shipping_type,round(AVG(purchase_amount::numeric),2) AS total_compras
FROM customer
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY Shipping_type
--Q5. ¿Los clientes suscritos gastan más? Compara el gasto promedio y el ingreso total entre suscriptores y no suscriptores.
SELECT Subscription_Status, 
       round(AVG(Purchase_Amount::numeric),2) AS promedio_total, 
       SUM(Purchase_Amount) AS total_suma
FROM customer
GROUP BY Subscription_Status
--Q6. ¿Qué 5 productos tienen el mayor porcentaje de compras con descuentos aplicados?
SELECT Item_Purchased, 
       COUNT(CASE WHEN Discount_Applied = 'Yes' THEN 1 END) * 100.0 / COUNT(*) AS porcentaje_descuento
FROM customer
GROUP BY Item_Purchased
ORDER BY porcentaje_descuento DESC
LIMIT 5;
--Q7. Segmenta a los clientes en "Nuevos", "Recurrentes" y "Leales" según su número total de compras anteriores, y muestra el recuento de cada segmento.
with customer_tipe as(
select customer_id,previous_purchases,
case 
	when previous_purchases = 1 then 'nuevos'
	when previous_purchases between 2 and 10 then 'recurrentes'
	else 'leales'
	end as segmentacion
from customer
)
select segmentacion, count(*) as "numero_de_clientes"
from customer_tipe
group by segmentacion
--Q8. ¿Cuáles son los 3 productos más comprados dentro de cada categoría?
SELECT category, item_purchased, purchase_count
FROM (
    SELECT Category AS category, Item_Purchased AS item_purchased, COUNT(*) AS purchase_count,
           RANK() OVER (PARTITION BY Category ORDER BY COUNT(*) DESC) as rank
    FROM customer
    GROUP BY Category, Item_Purchased
) AS ranked_products
WHERE rank <= 3;
--Q9. ¿Es probable que los clientes que son compradores frecuentes (más de 5 compras anteriores) también se suscriban?
SELECT Subscription_Status, COUNT(*) AS total
FROM customer
WHERE Previous_Purchases > 5
GROUP BY Subscription_Status;
--Q10. ¿Cuál es la contribución de ingresos de cada grupo de edad?
SELECT age_group, sum(purchase_amount) as total
from customer
group by age_group
order by total desc
