-- Enter the password into the database and select the appropriate database
-- Main query to retrieve sales data with percentage calculations
SELECT
  TOP (1000001) * 
FROM 
  (
    SELECT 
      -- Business dimensions for grouping
      [t1].[Product] AS [Product], 
      [t1].[Segment] AS [Segment], 
      -- Measure: Sum of sales for each product/segment combination
      SUM([t1].[Sales]) AS [Sales], 
      -- Window function: Calculate total sales across all rows in the result set
      SUM(
        SUM([t1].[Sales])
      ) OVER() AS [Total_Sales], 
      -- Percentage calculation: Individual sales divided by total sales
      -- FORMAT function used to display as percentage with 2 decimal places (e.g., 15.25%)
      FORMAT(
        100.0 * SUM([t1].[Sales]) / SUM(
          SUM([t1].[Sales])
        ) OVER(), 
        'N2'
      ) + '%' AS [Sales_Percentage] 
    FROM 
      -- Join sales data (financials) with calendar for date filtering
      (
        [dbo].[financials] AS [t1] 
        LEFT JOIN [dbo].[calendar] AS [t0] ON ([t1].[Date] = [t0].[Date])
      ) 
    WHERE 
      -- Filter conditions:
      -- 1. Specific month and year: December 2014
      -- 2. Specific country: United States of America
      -- 3. Complex product/segment combinations using OR logic
      (
        ([t0].[Year Month] = '2014 Dec') 
        AND (
          [t1].[Country] = 'United States of America'
        )
      ) 
      AND (
        -- First set of product/segment combinations
        (
          (
            ([t1].[Product] = 'Amarilla') 
            AND ([t1].[Segment] = 'Midmarket')
          ) 
          OR (
            ([t1].[Product] = 'Montana') 
            AND ([t1].[Segment] = 'Midmarket')
          )
        ) 
        OR -- Second set of product/segment combinations
        (
          (
            ([t1].[Product] = 'Amarilla') 
            AND (
              [t1].[Segment] = 'Small Business'
            )
          ) 
          OR (
            ([t1].[Product] = 'Velo') 
            AND (
              [t1].[Segment] = 'Small Business'
            )
          )
        ) 
        OR -- Third set of product/segment combinations
        (
          (
            ([t1].[Product] = 'Carretera') 
            AND ([t1].[Segment] = 'Government')
          ) 
          OR (
            ([t1].[Product] = 'Montana') 
            AND ([t1].[Segment] = 'Enterprise')
          ) 
          OR (
            ([t1].[Product] = 'Paseo') 
            AND ([t1].[Segment] = 'Enterprise')
          )
        ) 
        OR -- Fourth set of product/segment combinations
        (
          (
            ([t1].[Product] = 'Paseo') 
            AND (
              [t1].[Segment] = 'Channel Partners'
            )
          ) 
          OR (
            ([t1].[Product] = 'Velo') 
            AND (
              [t1].[Segment] = 'Channel Partners'
            )
          ) 
          OR (
            ([t1].[Product] = 'Paseo') 
            AND ([t1].[Segment] = 'Government')
          ) 
          OR (
            ([t1].[Product] = 'VTT') 
            AND ([t1].[Segment] = 'Government')
          )
        )
      ) -- Group by both dimensions to get aggregated sales per combination
    GROUP BY 
      [t1].[Segment], 
      [t1].[Product]
  ) AS [MainTable] 
WHERE 
  -- Exclude rows where sales value is NULL
  (
    NOT ([Sales] IS NULL)
  ) -- Sort results alphabetically by product name
ORDER BY 
  [Product];

--group 01
select
   c.year,
   [Year Month Number],
   sum(sales) 
from
   v_calendar c 
   left join
      v_financials f 
      on c.Date = f.Date 
group by
   rollup (c.[year], [Year Month Number]) 
order by
   [Year Month Number] 
--group 02
   select
      c.year,
      [Year Month Number],
      sum(sales) 
   from
      v_calendar c 
      left join
         v_financials f 
         on c.Date = f.Date 
   group by
      cube (c.[year], [Year Month Number]) 
   order by
      [Year Month Number] 
--group 03
      select
         c.year,
         [Year Month Number],
         sum(sales) 
      from
         v_calendar c 
         left join
            v_financials f 
            on c.Date = f.Date 
      group by
         grouping sets (rollup(c.[year], [Year Month Number]), cube(c.[year], [Year Month Number]) ) 
      order by
         [Year Month Number] 
--group 04
         select
            c.year,
            [Year Month Number],
            sum(sales) 
         from
            v_calendar c 
            left join
               v_financials f 
               on c.Date = f.Date 
         group by
            grouping sets (c.[year], [Year Month Number]) 
         order by
            [Year Month Number] 			
            

--https://learn.microsoft.com/en-us/sql/t-sql/queries/select-group-by-transact-sql?view=sql-server-ver17