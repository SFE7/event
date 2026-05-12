# 📘 RESUME 04 — Advanced Queries & Filtering

> **Course**: LAB-2 — Spring Data JPA: Relations OneToMany & Advanced JPQL Queries  
> **Section**: 4 of 6  
> **Topic**: Complex JPQL Queries, Multiple Criteria Filtering, Dynamic Queries

---

## ✅ Learning Objectives Checklist

By the end of this section, you should be able to:

- [ ] Write JPQL queries with multiple `WHERE` conditions using `AND` / `OR`
- [ ] Use `LIKE`, `BETWEEN`, comparison operators in JPQL
- [ ] Query across **joined entities** (e.g., filter products by category name)
- [ ] Use `ORDER BY` with `ASC` and `DESC` in JPQL
- [ ] Understand and write **aggregate functions** (`COUNT`, `MAX`, `MIN`, `AVG`, `SUM`)
- [ ] Use `GROUP BY` and `HAVING` in JPQL
- [ ] Apply `DISTINCT` to remove duplicate results
- [ ] Handle `NULL` values in JPQL queries (`IS NULL`, `IS NOT NULL`)
- [ ] Use `IN` and `NOT IN` clauses with collections
- [ ] Understand when to use derived query methods vs `@Query`

---

## 1. JPQL Fundamentals Review

### 1.1 JPQL vs SQL Quick Comparison

```sql
-- SQL (uses table/column names)
SELECT * FROM produit WHERE prix BETWEEN 10 AND 100 ORDER BY prix ASC;

-- JPQL (uses entity/field names)
SELECT p FROM Produit p WHERE p.prix BETWEEN 10 AND 100 ORDER BY p.prix ASC
```

### 1.2 Basic JPQL Structure

```
SELECT [alias] FROM [EntityName] [alias]
  [JOIN [alias].[field] [joinAlias]]
  [WHERE [conditions]]
  [GROUP BY [fields]]
  [HAVING [conditions]]
  [ORDER BY [field] [ASC|DESC]]
```

---

## 2. Single-Criteria Queries

### 2.1 Comparison Operators

```java
// Equal
@Query("SELECT p FROM Produit p WHERE p.prix = :prix")
List<Produit> findByExactPrix(@Param("prix") double prix);

// Greater Than
@Query("SELECT p FROM Produit p WHERE p.prix > :minPrix")
List<Produit> findMoreExpensiveThan(@Param("minPrix") double minPrix);

// Less Than or Equal
@Query("SELECT p FROM Produit p WHERE p.prix <= :maxPrix")
List<Produit> findUpToPrice(@Param("maxPrix") double maxPrix);

// BETWEEN (inclusive)
@Query("SELECT p FROM Produit p WHERE p.prix BETWEEN :min AND :max")
List<Produit> findByPrixBetween(@Param("min") double min, @Param("max") double max);
```

### 2.2 String Matching with LIKE

```java
// Contains (case-sensitive by default)
@Query("SELECT p FROM Produit p WHERE p.designation LIKE %:keyword%")
List<Produit> searchByKeyword(@Param("keyword") String keyword);

// Starts with
@Query("SELECT p FROM Produit p WHERE p.designation LIKE :prefix%")
List<Produit> findByDesignationStartingWith(@Param("prefix") String prefix);

// Case-insensitive search (LOWER function)
@Query("SELECT p FROM Produit p WHERE LOWER(p.designation) LIKE LOWER(CONCAT('%', :keyword, '%'))")
List<Produit> searchByKeywordIgnoreCase(@Param("keyword") String keyword);
```

### 2.3 NULL Checks

```java
// Products without a category
@Query("SELECT p FROM Produit p WHERE p.categorie IS NULL")
List<Produit> findProduitsWithoutCategorie();

// Products with a category assigned
@Query("SELECT p FROM Produit p WHERE p.categorie IS NOT NULL")
List<Produit> findProduitsWithCategorie();
```

---

## 3. Multi-Criteria Queries (AND / OR)

### 3.1 Combining Conditions with AND

```java
// Products by max price AND category name
@Query("SELECT p FROM Produit p WHERE p.prix <= :maxPrix AND p.categorie.nomCategorie = :nomCategorie")
List<Produit> findByPrixMaxAndCategorie(
    @Param("maxPrix") double maxPrix,
    @Param("nomCategorie") String nomCategorie
);

// Products by keyword AND minimum quantity
@Query("SELECT p FROM Produit p WHERE p.designation LIKE %:keyword% AND p.quantite > :minQte")
List<Produit> findAvailableByKeyword(
    @Param("keyword") String keyword,
    @Param("minQte") int minQte
);

// Three conditions combined
@Query("""
    SELECT p FROM Produit p 
    WHERE p.prix BETWEEN :min AND :max
    AND p.designation LIKE %:keyword%
    AND p.categorie.nomCategorie = :categorie
    """)
List<Produit> findByAllCriteria(
    @Param("min") double min,
    @Param("max") double max,
    @Param("keyword") String keyword,
    @Param("categorie") String categorie
);
```

### 3.2 Combining Conditions with OR

```java
// Products in one of two categories
@Query("SELECT p FROM Produit p WHERE p.categorie.nomCategorie = :cat1 OR p.categorie.nomCategorie = :cat2")
List<Produit> findByTwoCategories(
    @Param("cat1") String cat1,
    @Param("cat2") String cat2
);
```

### 3.3 IN Clause with Collections

```java
// Products whose category is in a given list
@Query("SELECT p FROM Produit p WHERE p.categorie.nomCategorie IN :noms")
List<Produit> findByCategorieNoms(@Param("noms") List<String> noms);

// Products NOT in a list of IDs
@Query("SELECT p FROM Produit p WHERE p.id NOT IN :ids")
List<Produit> findExcluding(@Param("ids") List<Long> ids);
```

---

## 4. Queries Across Related Entities

### 4.1 Filtering by Related Entity Fields

```java
// Method name approach (simpler for simple cases)
List<Produit> findByCategorieNomCategorie(String nom);

// JPQL equivalent — explicit path traversal
@Query("SELECT p FROM Produit p WHERE p.categorie.nomCategorie = :nom")
List<Produit> findByCategoryName(@Param("nom") String nom);

// JPQL with explicit JOIN (same result, more explicit)
@Query("SELECT p FROM Produit p JOIN p.categorie c WHERE c.nomCategorie = :nom")
List<Produit> findByCategoryNameJoin(@Param("nom") String nom);
```

### 4.2 Fetching Related Entities (JOIN FETCH)

```java
// Without JOIN FETCH: Produits are loaded lazily (extra queries per produit)
@Query("SELECT c FROM Categorie c")
List<Categorie> findAllCategories();

// WITH JOIN FETCH: Loads categories AND their produits in ONE query
@Query("SELECT DISTINCT c FROM Categorie c LEFT JOIN FETCH c.produits")
List<Categorie> findAllCategoriesWithProduits();
```

> 💡 `JOIN FETCH` solves the **N+1 query problem** by loading related entities in a single JOIN query.

---

## 5. Sorting and Ordering

### 5.1 Static ORDER BY in JPQL

```java
// Order by price ascending (cheapest first)
@Query("SELECT p FROM Produit p ORDER BY p.prix ASC")
List<Produit> findAllOrderByPrixAsc();

// Order by price descending (most expensive first)
@Query("SELECT p FROM Produit p ORDER BY p.prix DESC")
List<Produit> findAllOrderByPrixDesc();

// Multi-level sort: by category name, then by product name
@Query("SELECT p FROM Produit p ORDER BY p.categorie.nomCategorie ASC, p.designation ASC")
List<Produit> findAllOrderedByCategoryThenName();
```

### 5.2 Dynamic Sorting with Sort Parameter

```java
// Repository method with dynamic sorting
List<Produit> findByPrixBetween(double min, double max, Sort sort);

// How to call it:
List<Produit> results = produitRepository.findByPrixBetween(
    10.0, 100.0,
    Sort.by(Sort.Direction.ASC, "prix")
);

// Or with multiple sort fields:
Sort multiSort = Sort.by("categorie.nomCategorie").ascending()
                     .and(Sort.by("prix").descending());
List<Produit> sorted = produitRepository.findAll(multiSort);
```

---

## 6. Aggregate Functions

### 6.1 Basic Aggregates

```java
// Count all products
@Query("SELECT COUNT(p) FROM Produit p")
long countAllProduits();

// Count products in a specific category
@Query("SELECT COUNT(p) FROM Produit p WHERE p.categorie.nomCategorie = :nom")
long countByCategorie(@Param("nom") String nom);

// Max price
@Query("SELECT MAX(p.prix) FROM Produit p")
Double findMaxPrix();

// Min price
@Query("SELECT MIN(p.prix) FROM Produit p")
Double findMinPrix();

// Average price
@Query("SELECT AVG(p.prix) FROM Produit p")
Double findAvgPrix();

// Total stock value (sum of prix * quantite)
@Query("SELECT SUM(p.prix * p.quantite) FROM Produit p")
Double calculateTotalStockValue();
```

### 6.2 GROUP BY and HAVING

```java
// Count products per category
@Query("SELECT c.nomCategorie, COUNT(p) FROM Produit p JOIN p.categorie c GROUP BY c.nomCategorie")
List<Object[]> countByCategory();

// Categories with more than 5 products (HAVING)
@Query("SELECT c.nomCategorie FROM Produit p JOIN p.categorie c GROUP BY c.nomCategorie HAVING COUNT(p) > :minCount")
List<String> findCategoriesWithMoreThan(@Param("minCount") long minCount);

// Average price per category
@Query("SELECT c.nomCategorie, AVG(p.prix) FROM Produit p JOIN p.categorie c GROUP BY c.nomCategorie")
List<Object[]> avgPricePerCategory();
```

### 6.3 Processing Object Array Results

```java
// The service processes the raw Object[] results
public Map<String, Long> getProductCountByCategory() {
    List<Object[]> rows = produitRepository.countByCategory();
    Map<String, Long> result = new LinkedHashMap<>();
    for (Object[] row : rows) {
        String categorieName = (String) row[0];
        Long count = (Long) row[1];
        result.put(categorieName, count);
    }
    return result;
}
```

---

## 7. DISTINCT Queries

```java
// Get unique category names from products (avoid duplicates)
@Query("SELECT DISTINCT p.categorie.nomCategorie FROM Produit p")
List<String> findDistinctCategoryNames();

// Get distinct products (e.g., if JOINs create duplicates)
@Query("SELECT DISTINCT p FROM Produit p JOIN p.categorie c WHERE c.nomCategorie LIKE %:keyword%")
List<Produit> findDistinctByCategory(@Param("keyword") String keyword);
```

---

## 8. Text Blocks for Complex Queries (Java 15+)

```java
// Use text blocks (triple quotes) for multi-line JPQL queries
@Query("""
    SELECT p FROM Produit p
    WHERE p.prix BETWEEN :min AND :max
    AND p.quantite > 0
    AND p.designation LIKE %:keyword%
    ORDER BY p.categorie.nomCategorie ASC, p.prix ASC
    """)
List<Produit> findAvailableByPriceAndKeyword(
    @Param("min") double min,
    @Param("max") double max,
    @Param("keyword") String keyword
);
```

---

## 9. Method Naming vs @Query — When to Use Which

| Scenario | Use | Reason |
|----------|-----|--------|
| Simple equality check | Derived method | `findByDesignation(String d)` |
| Single field `LIKE` | Derived method | `findByDesignationContaining(String k)` |
| Single range query | Derived method | `findByPrixBetween(double a, double b)` |
| Multiple conditions | `@Query` | Derived names become very long |
| Case-insensitive search | `@Query` | Needs `LOWER()` function |
| Aggregates | `@Query` | No derived method support |
| GROUP BY / HAVING | `@Query` | No derived method support |
| JOIN FETCH | `@Query` | Performance optimization not available via derived methods |
| Complex expressions | `@Query` | Full JPQL expressiveness |

---

## 10. Best Practices

### ✅ Do This

```java
// ✅ Use named parameters for clarity and reorder-safety
@Query("SELECT p FROM Produit p WHERE p.prix BETWEEN :min AND :max")
List<Produit> find(@Param("min") double min, @Param("max") double max);

// ✅ Use text blocks for long queries
@Query("""
    SELECT p FROM Produit p
    WHERE p.categorie.nomCategorie = :nom
    ORDER BY p.prix ASC
    """)
List<Produit> findByCategory(@Param("nom") String nom);

// ✅ Use JOIN FETCH for collections to avoid N+1
@Query("SELECT DISTINCT c FROM Categorie c LEFT JOIN FETCH c.produits")
List<Categorie> findAllWithProduits();
```

### ❌ Avoid This

```java
// ❌ NEVER concatenate user input into queries — SQL injection risk!
String query = "SELECT p FROM Produit p WHERE p.designation LIKE '%" + userInput + "%'";
// Use parameters instead:
@Query("SELECT p FROM Produit p WHERE p.designation LIKE %:keyword%")
List<Produit> search(@Param("keyword") String keyword);

// ❌ Avoid Cartesian products (missing JOIN condition)
@Query("SELECT p, c FROM Produit p, Categorie c")  // Missing WHERE/JOIN!
// This returns every product paired with every category!

// ❌ Don't load all data and filter in Java
List<Produit> all = produitRepository.findAll();
List<Produit> filtered = all.stream()
    .filter(p -> p.getPrix() > 100).collect(toList()); // Move this to DB!
```

---

## 11. Common Mistakes to Avoid

| Mistake | Consequence | Fix |
|---------|-------------|-----|
| Using table names in JPQL | `QuerySyntaxException` | Use entity class names (e.g., `Produit`, not `produit`) |
| Using column names in JPQL | `QuerySyntaxException` | Use Java field names (e.g., `nomCategorie`, not `nom_categorie`) |
| Forgetting `@Param` | Query fails, params not bound | Add `@Param("name")` to each method parameter |
| Missing `DISTINCT` with JOIN FETCH on collections | Duplicate rows returned | Add `DISTINCT` when joining collections |
| Using `SELECT *` in JPQL | Syntax error | Use `SELECT p` with an alias |
| Positional params out of order | Wrong values bound to params | Prefer named params |

---

## 12. Review Questions

1. Write a JPQL query that finds all products where the price is less than 500 AND the category name contains "Info".

2. What is the difference between `JOIN` and `JOIN FETCH` in JPQL? When would you use each?

3. How would you write a query to find the average price of products per category? What return type would you use?

4. Why is it dangerous to concatenate user input directly into a JPQL query string? How do named parameters prevent this?

5. What does `DISTINCT` do in a JPQL query? When is it necessary?

6. Explain the N+1 query problem and how `JOIN FETCH` solves it.

7. When would you choose `@Query` over a derived query method? Give two examples.

8. How do you sort results dynamically at runtime (not hardcoded in the query)?

---

## 13. Practice Exercises

### Exercise 1 — Write Complex Queries
In `ProduitRepository`, add:
- Query: Products cheaper than `maxPrix` in a given category, ordered by price ascending
- Query: The 3 most expensive products across all categories
- Query: Categories that have at least one product with price > 1000

### Exercise 2 — Aggregate Statistics
Create a service method `getStatsProduits()` that returns:
- Total number of products
- Average price
- Most expensive product
- Least expensive product
- Total stock value (sum of prix × quantite)

### Exercise 3 — Multi-Criteria Search
Implement a `searchProduits(String keyword, Double maxPrix, String categorie)` method that:
- Ignores null parameters (dynamic filtering)
- Returns results ordered by price
- Handles case-insensitive keyword search

---

## 14. Summary

| Concept | Key Takeaway |
|---------|-------------|
| JPQL uses entity names | Not table names — use `Produit`, not `produit` |
| Named parameters | `:paramName` + `@Param("paramName")` — preferred |
| `AND` / `OR` | Combine multiple conditions in `WHERE` clause |
| `ORDER BY` | Sort results in JPQL or with Spring `Sort` object |
| Aggregate functions | `COUNT`, `MAX`, `MIN`, `AVG`, `SUM` — work in JPQL |
| `JOIN FETCH` | Solves N+1 problem by loading collections in one query |
| `DISTINCT` | Prevents duplicate rows when joining collections |
| `@Query` vs derived | Use `@Query` for complex queries with multiple conditions |

---

## ➡️ Next Section

**[RESUME-05 → Testing & Validation](./RESUME-05-Testing-and-Validation.md)**  
Learn how to write proper unit tests and integration tests using JUnit 5 and the AAA pattern.

---

*📑 Back to [Index](./INDEX-Resumes.md)*
