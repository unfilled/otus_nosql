# 12 Neo4j

Neo4j был запущен из контейнера (Docker Desktop, Win 10 Home, WSL2 enabled):
```bash
docker run --name testneo4j -p7474:7474 -p7687:7687 -d -v $HOME/neo4j/data:/data -v $HOME/neo4j/logs:/logs -v $HOME/neo4j/import:/var/lib/neo4j/import -v $HOME/neo4j/plugins:/plugins --env NEO4J_AUTH=neo4j/test neo4j:latest
```
Для доступа использовался web-интерфейс по адресу [http://localhost:7474/](http://localhost:7474/).

Была создана БД с мужчинами и женщинами. Узлы - мужчины (male) и женщины (female). Мужчины и женщины могут быть женаты (MARRIED) - в случае этой связи направление не играет значения и в запросах не учитывается. Женщинам могут нравиться (LIKES) другие женщины. А мужчины могуть быть должны (OWES_TO) другим мужчинам.

Запрос для создания БД (узлы и связи):
```
CREATE (mn:male {Name:'Никита'})
CREATE (mi:male {Name:'Игорь'})
CREATE (mv:male {Name:'Ваня'})
CREATE (ma:male {Name:'Андрей'})
CREATE (ms:male {Name:'Саша'})
CREATE (mm:male {Name:'Миша'})

CREATE (fa:female {Name:'Аня'})
CREATE (fm:female {Name:'Маша'})
CREATE (fs:female {Name:'Света'})
CREATE (fk:female {Name:'Катя'})
CREATE (fn:female {Name:'Настя'})
   
CREATE 
    (ms) - [:MARRIED {since:2009}] -> (fa),
    (mn) - [:MARRIED {since:2012}] -> (fm),
    (mi) - [:MARRIED {since:2005}] -> (fs),
    (mv) - [:MARRIED {since:2017}] -> (fk),
    (ma) - [:MARRIED {since:2020}] -> (fn)

CREATE
    (fa) - [:LIKES] -> (fm),
    (fa) - [:LIKES] -> (fs),
    (fa) - [:LIKES] -> (fk),
    (fm) - [:LIKES] -> (fa),
    (fs) - [:LIKES] -> (fm),
    (fs) - [:LIKES] -> (fk),
    (fs) - [:LIKES] -> (fn),
    (fk) - [:LIKES] -> (fm),
    (fk) - [:LIKES] -> (fn),
    (fn) - [:LIKES] -> (fm),
    (fn) - [:LIKES] -> (fs)
    
CREATE 
    (mn) - [:OWES_TO {sum: 1500}] -> (mi),
    (mi) - [:OWES_TO {sum: 900}] -> (mv),
    (mi) - [:OWES_TO {sum: 200}] -> (ma),
    (mv) - [:OWES_TO {sum: 900}] -> (ma),
    (ms) - [:OWES_TO {sum: 150}] -> (mm),
    (mm) - [:OWES_TO {sum: 500}] -> (ma)
```

Ниже приведены запросы для:    
1) Поиска человека по имени:
```    
MATCH (m {Name: "Миша"}) RETURN m
```
2) Поиска любых связей Игоря с другими узлами (так же указывается какая связь):
```
MATCH ({Name: "Игорь"})-[relatedTo]-() RETURN startNode(relatedTo).Name, Type(relatedTo), 
relatedTo, endNode(relatedTo).Name
```
3) Поиска мужчин, жёны которых нравятся жене Игоря (выводятся и мужчины, и женщины со всеми связями)
```
MATCH (m {Name: "Игорь"})-[:MARRIED]->(f)<-[:LIKES]-(fem),
(fem)-[:MARRIED]-(m2)
RETURN m, f, fem, m2
```
4) Поиска пары, женатой дольше всех:
```
MATCH (m)-[s:MARRIED]->(f)
RETURN m, f
ORDER BY s.since 
LIMIT 1
```
5) Поиск двух мужчин, которые должны больше всех:
```
MATCH (m)-[o:OWES_TO]->(:male)
RETURN m.Name, SUM(o.sum) AS sum
ORDER BY sum DESC
LIMIT 2
```
6) Поиск мужчины, которому должны больше всех:
```
MATCH (m)<-[o:OWES_TO]-(:male)
RETURN m.Name, SUM(o.sum) AS sum
ORDER BY sum DESC
LIMIT 1
```
7) Вывод имён женщин и количества других женщин, которым они нравятся:
```
MATCH (f)<-[:LIKES]-()
RETURN f.Name, COUNT(*) AS Power
ORDER BY Power DESC
```

Удаление всех узлов и связей:
```
MATCH(n) DETACH DELETE n
```
