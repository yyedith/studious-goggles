---1--What is the total number of parts per theme?



---Note: We first inspect the dataset. Since the Rebrickable website
---gives a helpful graphic to see how all the data is connected, we will use it as a guide throughout this project..
---As for the question and according to the graphic, we can join 'sets' to 'themes'.

-- Batch 1: Create the view
--CREATE VIEW dbo.question_1 AS
--SELECT s.set_num, s.name AS set_name, s.year, s.theme_id, CAST(s.num_parts AS NUMERIC) num_parts, t.name as theme_name, 
	--t.parent_id, p.name as parent_theme_name
--FROM dbo.sets s
--LEFT JOIN [dbo].[themes] t
	--ON s.theme_id = t.id
--LEFT JOIN [dbo].[themes] p
	--ON t.parent_id = p.id
--GO 

-- Batch 2: Select from the view
SELECT * FROM dbo.question_1;

---Now we can make more simple queries. However, I will still leave the code for creating the view as a reference.
SELECT theme_name, sum(num_parts) AS total_num_parts FROM question_1
--WHERE parent_theme_name IS NOT NULL
GROUP BY theme_name
ORDER BY 2 DESC
---Based on the data, 'Technic' is the number 1 theme with the most number of parts. 
---We notice that when we do the join, there are multiple 'parent_theme_name' cells which are null. 
---So, we can add a query to exclude these from our data. When we do this, the 'Ultimate Collector Series'
---becomes the #1 theme with the most total number of parts.

---2--What is the total number of parts per year?
SELECT year, sum(num_parts) AS total_num_parts FROM question_1
WHERE parent_theme_name IS NOT NULL
GROUP BY year
ORDER BY 2 DESC
---According to the dataset, whenever we do not include the parent theme as part of the selection criteria, the year 2022
---is the year where LEGO created the most number of parts. We also see that 2023 actually takes 5th place. This makes sense
---since we are still in 2023 so there is still more time for them to create more parts. Also 2021 and 2020 take 2nd and 3rd place
---respectively which is surprising given the COVID-19 pandemic. One would expect 2020 to be more lower since almost everything came to 
---a halt in that particular year.
---However, if we exclude cells that are null, 2017 takes 1st place for total number of parts. In fact, between 2014 and 2017 there is a 
---large gap in the numbers. This time, 2020 is placed at #14 for the total number of parts. 

---3--How many sets were created in each century in the dataset?
SELECT century, COUNT(set_num) AS total_num_sets FROM question_1
--WHERE parent_theme_name IS NOT NULL
GROUP BY century
---LEGO created 5046 sets in the 20th century and 16288 sets in the 21st century which is a huge gap. Now, let's see if excluding null cells 
---under parent theme gives us the same results. 
---Based on the table, the gap is not as large anymore with the 21st century having 7870 sets in total and the 20th century having 3732 sets.


--4--What percentage of sets ever released in the 21st century were trains themed?

;WITH lego as 
(
	SELECT century, theme_name, COUNT(set_num) total_set_num 
	FROM dbo.question_1
	WHERE century = '21st_century'
	GROUP BY century, theme_name
)

SELECT SUM(total_set_num), SUM(percentage)
FROM(
	SELECT century, theme_name, total_set_num, sum(total_set_num) OVER() as total, CAST(1.00*total_set_num/sum(total_set_num) OVER() AS DECIMAL(5,4))*100 percentage
	FROM lego
	)m
WHERE theme_name like '%star wars%'
---Now that we have the total count for each theme, we need to make a subquery to calculate the percentage (we did this above).
---Looking at our dataset, there are two versions for the theme name we are looking for which are 'train' and 'trains.' making it more complicated to calculate percentage.
---In order to fix this, we need to add a subquery, so we will do that in our next step.

---According to the dataset, the theme of trains made up 0.42% of sets released in the 21st century.
---We can look at other themes to see how their percentages compare.
---When looking at the Disney theme, we get that 1.42% of sets from the 21st century were of this type. 
---This is 5.31% for Star Wars themed sets.


---5---What was the most popular theme by year in terms of sets released in the 21st century?
SELECT year, theme_name, total_set_num
FROM(
	SELECT year, theme_name, COUNT(set_num) total_set_num, ROW_NUMBER() OVER(partition by year order by count(set_num) desc) rn
	FROM question_1
	WHERE century = '21st_century'
		--AND parent_theme_name IS NOT NULL
	GROUP BY year, theme_name
	)m 
WHERE rn = 1
ORDER BY year desc

---This answer depends on whether we decide to exclude cells where the parent theme name is null. If we apply this condition, the 
---popular theme is Key Chain from 2020 to 2022. For this year of 2023, it is Disney 100 so far. However, if we take off this condition, 
---our results say that Star Wars was the most popular theme from 2015 - 2018. Also, the theme Friends seems to be the most popular this year
---of 2023 so far.

---6---What is the most popular color of LEGO's regarding the quantity of parts?
SELECT color_name, sum(quantity) as quantity_of_parts
FROM (
		SELECT 
			inv.color_id, inv.inventory_id, inv.part_num, CAST(inv.quantity AS NUMERIC) quantity, inv.is_spare, c.name AS color_name, c.rgb, p.name as part_name, p.part_material, pc.name AS category_name
		FROM inventory_parts inv
		INNER JOIN colors c
			ON inv.color_id = c.id
		INNER JOIN  parts p 
			ON inv.part_num = p.part_num
		INNER JOIN part_categories pc
			ON part_cat_id = pc.id
	)main
GROUP BY color_name
ORDER BY 2 DESC
---According to the data, black is the most common color among the produced LEGO parts with over 721,000 parts of this color. The 2nd most popular color
---is Light Bluish Gray which has slightly over 437,000 in terms of quantity of LEGO parts. White comes in 3rd place with slightly over 429,000
---parts of this color. Thus, it seems like shades are more popular in terms of quantity compared to colorful parts. In fact, the color Red comes 
---in at 5th place. All the other colors above it are shades. 