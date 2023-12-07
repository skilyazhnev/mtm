# max_to_min() agreegate func

Aggregate function that generates a custom-formatted text for a given numerical column, displaying the minimum and maximum values of that column.

## Installation

In target server 
```bash
git clone 
cd ./mtm
make install
```
In target database run
```sql
create extension mtm version "0.1" ;
```

## Configuration

Parameters can be configured in `postgresql.conf` or in session  

- `mtm.output_format`: Output format based in `FORMAT()` [(Doc)](https://www.postgresql.org/docs/current/functions-string.html#FUNCTIONS-STRING-FORMAT) <br>
**important**: I didn't add the ability to change the order of maximum and minimum because this would begin to contradict the name of the function

## Examples

Clear calling
```sql
SELECT max_to_min(val)
    FROM (VALUES(5),(3),(6),(7),(9),(10),(7)) t(val);

max_to_min 
-----------
 10 -> 3
```

```sql
-- Change output format in session
set mtm.output_format='%s -> %s';
select max_to_min(val), text from t group by text;
  max_to_min | text
------------+------
 0 -> 0     | Q
 10 -> 2    | B
 1 -> 1     | k
 4 -> 1     | A
 -1 -> -1   | l
 12 -> 1    | F
(6 rows)

-- Change output format in session
SET mtm.output_format='{ "max": %I, "min": %I }';
SELECT max_to_min(val), text FROM t GROUP BY text;

          max_to_min          | text
------------------------------+------
 { "max": "0", "min": "0" }   | Q
 { "max": "10", "min": "2" }  | B
 { "max": "1", "min": "1" }   | k
 { "max": "4", "min": "1" }   | A
 { "max": "-1", "min": "-1" } | l
 { "max": "12", "min": "1" }  | F
(6 rows)
```




## Notes

Как вариант можно было бы использовать Polymorphic Types, но я ограничился на решении с числами.