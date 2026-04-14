# 📘 RESUME 02 — Data Access with Repositories

> **Course**: LAB-2 — Spring Data JPA: Relations OneToMany & Advanced JPQL Queries  
> **Section**: 2 of 6  
> **Topic**: Spring Data JPA Repositories, Query Methods, JPQL Basics

---

## ✅ Learning Objectives Checklist

By the end of this section, you should be able to:

- [ ] Explain the purpose of the Repository pattern in Spring applications
- [ ] Create a `JpaRepository` interface for an entity
- [ ] Use built-in CRUD methods from `JpaRepository`
- [ ] Define custom query methods using Spring Data's **method naming conventions**
- [ ] Write **JPQL queries** using `@Query` annotation
- [ ] Understand the difference between JPQL and native SQL
- [ ] Use named parameters (`:param`) and positional parameters (`?1`) in queries
- [ ] Apply `@Param` to bind method parameters to query parameters
- [ ] Use `findBy`, `countBy`, `existsBy`, `deleteBy` prefixes
- [ ] Implement keyword-based query methods (`Containing`, `StartingWith`, `Between`, etc.)

---

## 1. Core Concepts

### 1.1 The Repository Pattern

The Repository pattern **abstracts the data access layer** from the business logic. Instead of writing SQL or JDBC code, you define an interface and Spring generates the implementation automatically.

```
Controller / Service
        │
        │  calls
        ▼
  ┌──────────────┐
  │  Repository  │  ← Your interface (extends JpaRepository)
  └──────────────┘
        │
        │  Spring generates implementation
        ▼
  ┌──────────────┐
  │  Hibernate   │  ← JPA implementation translates to SQL
  └──────────────┘
        │
        ▼
  ┌──────────────┐
  │   Database   │
  └──────────────┘
```

### 1.2 Spring Data JPA Repository Hierarchy

```
Repository<T, ID>                  ← Marker interface (empty)
    └── CrudRepository<T, ID>      ← Basic CRUD: save, findById, findAll, delete
          └── PagingAndSortingRepository<T, ID>  ← + pagination & sorting
                └── JpaRepository<T, ID>         ← + flush, saveAndFlush, deleteInBatch
```

> 💡 In this lab, we extend **`JpaRepository<T, ID>`** which provides all CRUD operations plus JPA-specific methods.

---

## 2. Creating Repository Interfaces

### 2.1 CategorieRepository

```java
package ma.projet.repositories;

import ma.projet.entities.Categorie;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CategorieRepository extends JpaRepository<Categorie, Long> {
    // T = Categorie (entity type)
    // ID = Long (type of the primary key)
    
    // Spring Data JPA provides all basic CRUD operations automatically!
}
```

### 2.2 ProduitRepository

```java
package ma.projet.repositories;

import ma.projet.entities.Produit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ProduitRepository extends JpaRepository<Produit, Long> {
    
    // --- Derived Query Methods (auto-implemented by Spring Data) ---
    
    List<Produit> findByDesignationContaining(String keyword);
    
    List<Produit> findByPrixBetween(double min, double max);
    
    List<Produit> findByCategorieNomCategorie(String nomCategorie);
    
    // --- JPQL Queries ---
    
    @Query("SELECT p FROM Produit p WHERE p.designation LIKE %:keyword%")
    List<Produit> searchByDesignation(@Param("keyword") String keyword);
    
    @Query("SELECT p FROM Produit p WHERE p.prix BETWEEN :min AND :max ORDER BY p.prix ASC")
    List<Produit> findByPrixRange(@Param("min") double min, @Param("max") double max);
}
```

---

## 3. Built-in JpaRepository Methods

### 3.1 Save / Update

```java
// Save (insert if new, update if existing)
Produit saved = produitRepository.save(produit);

// Save multiple at once
List<Produit> savedAll = produitRepository.saveAll(listOfProduits);
```

### 3.2 Find / Read

```java
// Find by ID (returns Optional<T>)
Optional<Produit> opt = produitRepository.findById(1L);
Produit p = opt.orElseThrow(() -> new RuntimeException("Not found"));

// Find all records
List<Produit> all = produitRepository.findAll();

// Find all with sorting
List<Produit> sorted = produitRepository.findAll(Sort.by("prix").ascending());

// Check if exists
boolean exists = produitRepository.existsById(1L);

// Count all
long count = produitRepository.count();
```

### 3.3 Delete

```java
// Delete by ID
produitRepository.deleteById(1L);

// Delete by entity
produitRepository.delete(produit);

// Delete all
produitRepository.deleteAll();
```

---

## 4. Derived Query Methods (Method Naming Conventions)

Spring Data JPA can generate SQL queries by **parsing method names**. This eliminates the need to write `@Query` for simple queries.

### 4.1 Structure of a Derived Query Method

```
findBy    [FieldName]     [Condition]   [Connector]  [FieldName]  [Condition]
────────  ──────────────  ────────────  ───────────  ───────────  ────────────
findBy    Designation     Containing                              
findBy    Prix            Between       And          Quantite     GreaterThan
findBy    Categorie       NomCategorie
```

### 4.2 Common Keywords

| Keyword | SQL Equivalent | Example |
|---------|----------------|---------|
| `Containing` | `LIKE '%value%'` | `findByDesignationContaining("laptop")` |
| `StartingWith` | `LIKE 'value%'` | `findByDesignationStartingWith("A")` |
| `EndingWith` | `LIKE '%value'` | `findByDesignationEndingWith("Pro")` |
| `Between` | `BETWEEN min AND max` | `findByPrixBetween(10.0, 50.0)` |
| `LessThan` | `< value` | `findByQuantiteLessThan(5)` |
| `GreaterThan` | `> value` | `findByPrixGreaterThan(100.0)` |
| `GreaterThanEqual` | `>= value` | `findByPrixGreaterThanEqual(100.0)` |
| `IsNull` | `IS NULL` | `findByCategorieIsNull()` |
| `IsNotNull` | `IS NOT NULL` | `findByCategorieIsNotNull()` |
| `OrderBy` | `ORDER BY` | `findByOrderByPrixAsc()` |
| `And` | `AND` | `findByDesignationAndPrix(...)` |
| `Or` | `OR` | `findByDesignationOrPrix(...)` |
| `Not` | `NOT` | `findByDesignationNot("value")` |
| `In` | `IN (...)` | `findByIdIn(List<Long> ids)` |

### 4.3 Traversing Nested Properties

```java
// Access related entity's field using underscore or camelCase
List<Produit> findByCategorieNomCategorie(String nom);
//             ^^^^^^^^^  ^^^^^^^^^^^^
//             entity     field of that entity

// This generates: SELECT * FROM produit p
//                 JOIN categorie c ON p.categorie_id = c.id
//                 WHERE c.nom_categorie = :nom
```

---

## 5. JPQL Queries with @Query

### 5.1 JPQL vs Native SQL

| Feature | JPQL | Native SQL |
|---------|------|------------|
| Uses | Entity/field names | Table/column names |
| Database independent | ✅ Yes | ❌ No |
| Annotation | `@Query("SELECT p FROM Produit p...")` | `@Query(value="SELECT * FROM produit...", nativeQuery=true)` |
| Performance | Good | Can be faster for complex queries |

### 5.2 Named Parameters

```java
// ✅ RECOMMENDED: Named parameters with @Param
@Query("SELECT p FROM Produit p WHERE p.prix BETWEEN :min AND :max")
List<Produit> findByPrixRange(@Param("min") double min, @Param("max") double max);

// Call it like this:
List<Produit> results = produitRepository.findByPrixRange(10.0, 50.0);
```

### 5.3 Positional Parameters

```java
// Positional parameters (1-indexed)
@Query("SELECT p FROM Produit p WHERE p.prix BETWEEN ?1 AND ?2")
List<Produit> findByPrixRange(double min, double max);
```

### 5.4 JPQL with JOINs

```java
// Explicit JOIN
@Query("SELECT p FROM Produit p JOIN p.categorie c WHERE c.nomCategorie = :nom")
List<Produit> findByCategoryName(@Param("nom") String nom);

// JPQL uses entity field path notation (no explicit JOIN needed for simple cases)
@Query("SELECT p FROM Produit p WHERE p.categorie.nomCategorie = :nom")
List<Produit> findByCategoryNameSimple(@Param("nom") String nom);
```

### 5.5 JPQL with LIKE

```java
// Using LIKE with wildcard
@Query("SELECT p FROM Produit p WHERE p.designation LIKE %:keyword%")
List<Produit> searchByDesignation(@Param("keyword") String keyword);

// Equivalent to SQL: SELECT * FROM produit WHERE designation LIKE '%keyword%'
```

### 5.6 JPQL with ORDER BY

```java
@Query("SELECT p FROM Produit p ORDER BY p.prix DESC")
List<Produit> findAllOrderByPrixDesc();

@Query("SELECT p FROM Produit p WHERE p.categorie.id = :catId ORDER BY p.designation ASC")
List<Produit> findByCategoryOrderedByName(@Param("catId") Long catId);
```

---

## 6. Return Types

| Return Type | Use Case |
|-------------|----------|
| `List<T>` | Multiple results |
| `Optional<T>` | Single result (may or may not exist) |
| `T` | Single result (throws exception if not found) |
| `long` | Count operations |
| `boolean` | Exists checks |
| `void` | Delete operations |
| `Page<T>` | Paginated results |
| `Slice<T>` | Paginated results without total count |

---

## 7. Best Practices

### ✅ Do This

```java
// Use Optional for findById to safely handle missing entities
Optional<Produit> opt = produitRepository.findById(id);
Produit p = opt.orElseThrow(() -> new EntityNotFoundException("Produit not found: " + id));

// Use @Param with named parameters for readability
@Query("SELECT p FROM Produit p WHERE p.prix > :minPrix")
List<Produit> findExpensive(@Param("minPrix") double minPrix);

// Keep repository interfaces focused — one per entity
public interface ProduitRepository extends JpaRepository<Produit, Long> { ... }
public interface CategorieRepository extends JpaRepository<Categorie, Long> { ... }
```

### ❌ Avoid This

```java
// ❌ Don't load all data and filter in Java — use database queries
List<Produit> all = produitRepository.findAll();
// Then filtering in Java is inefficient for large datasets!

// ❌ Don't write queries that will cause N+1 problems
// (fetch each Categorie's produits one by one in a loop)
for (Categorie c : categories) {
    c.getProduits(); // Triggers one query per category!
}

// ❌ Don't ignore Optional — always handle the absent case
Produit p = produitRepository.findById(id).get(); // Throws NoSuchElementException if absent!
```

---

## 8. Common Mistakes to Avoid

| Mistake | Consequence | Fix |
|---------|-------------|-----|
| Using `.get()` on Optional without checking | `NoSuchElementException` at runtime | Use `orElseThrow()` or `orElse()` |
| Misspelling field names in derived queries | `PropertyReferenceException` at startup | Check entity field names carefully |
| Forgetting `@Param` with named parameters | Parameter not bound, query fails | Always use `@Param` with `:paramName` syntax |
| Writing native SQL that is database-specific | Application breaks when DB changes | Prefer JPQL unless performance requires native SQL |
| Creating queries that load all data | Memory issues with large datasets | Use pagination (`Page<T>`) |

---

## 9. Review Questions

1. What is the difference between `CrudRepository` and `JpaRepository`? Why do we typically use `JpaRepository`?

2. Explain how Spring Data JPA derives SQL from method names. Give an example of a method name and the SQL it generates.

3. Write a derived query method that finds all products whose price is between `min` and `max`, ordered by price ascending.

4. What is the difference between JPQL and native SQL? When would you use each?

5. What is the purpose of `@Param` annotation? Can you omit it?

6. What does `Optional<Produit>` returned by `findById()` protect against compared to returning `Produit` directly?

7. How would you write a JPQL query to find all products whose category name contains a given keyword?

8. What is the N+1 query problem? How can you avoid it in Spring Data JPA?

---

## 10. Practice Exercises

### Exercise 1 — Repository Methods
In `ProduitRepository`, add the following query methods:
- Find all products whose quantity is less than a given threshold (low stock alert)
- Find products ordered by price descending
- Count products in a given category
- Check if a product with a specific designation exists

### Exercise 2 — JPQL Queries
Write JPQL queries for:
- All products with `prix > 100` that belong to a category named "Electronique"
- All categories that have at least one product
- The most expensive product in each category

### Exercise 3 — Custom Repository Method
Add a method to `CategorieRepository` that:
- Finds all categories whose name starts with a given prefix, ordered alphabetically
- Test it with the prefix "Info"

---

## 11. Summary

| Concept | Key Takeaway |
|---------|-------------|
| `JpaRepository<T, ID>` | Provides all CRUD operations for free |
| Derived query methods | Method names are parsed into SQL automatically |
| `@Query` | For complex queries that can't be expressed as method names |
| Named parameters | Use `:paramName` + `@Param("paramName")` for readability |
| JPQL | SQL-like language that uses entity/field names, not table/column names |
| `Optional<T>` | Safe way to handle entities that may not exist |

---

## ➡️ Next Section

**[RESUME-03 → Service Layer Architecture](./RESUME-03-Service-Layer.md)**  
Learn how to create a proper service layer that separates business logic from data access.

---

*📑 Back to [Index](./INDEX-Resumes.md)*
