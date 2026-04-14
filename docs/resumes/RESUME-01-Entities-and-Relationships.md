# 📘 RESUME 01 — Understanding Entities & Relationships

> **Course**: LAB-2 — Spring Data JPA: Relations OneToMany & Advanced JPQL Queries  
> **Section**: 1 of 6  
> **Topic**: JPA Entities, Annotations, and OneToMany / ManyToOne Relationships

---

## ✅ Learning Objectives Checklist

By the end of this section, you should be able to:

- [ ] Define what a JPA Entity is and why it is needed
- [ ] Apply core JPA annotations (`@Entity`, `@Id`, `@GeneratedValue`, `@Column`)
- [ ] Design a **OneToMany** relationship between two entities
- [ ] Design the inverse **ManyToOne** relationship
- [ ] Use `@JoinColumn` to control the foreign key in the database
- [ ] Understand **cascading** and **fetch types** (EAGER vs LAZY)
- [ ] Map Java object relationships to relational database tables
- [ ] Use `@ToString.Exclude` and `@JsonIgnore` to prevent infinite loops
- [ ] Create entities with Lombok annotations to reduce boilerplate code

---

## 1. Core Concepts

### 1.1 What Is a JPA Entity?

A **JPA Entity** is a plain Java class (POJO) that is mapped to a database table. Each instance of the class corresponds to one row in the table.

```
Java Class  ──────────────────►  Database Table
──────────                        ──────────────
Categorie                         categorie
  - id (Long)                       - id (BIGINT, PK)
  - nomCategorie (String)           - nom_categorie (VARCHAR)
  - produits (List<Produit>)        [→ FK in produit table]
```

### 1.2 The Domain Model

This lab manages a product catalog with two main entities:

```
┌─────────────────────┐         ┌────────────────────────┐
│      Categorie      │ 1     * │        Produit          │
├─────────────────────┤◄────────┤────────────────────────┤
│ - id: Long          │         │ - id: Long             │
│ - nomCategorie: Str │         │ - designation: String  │
│ - produits: List<P> │         │ - prix: double         │
└─────────────────────┘         │ - quantite: int        │
                                │ - categorie: Categorie │
                                └────────────────────────┘
```

**Relationship Rule**: One `Categorie` contains many `Produit`s. Each `Produit` belongs to exactly one `Categorie`.

---

## 2. JPA Annotations Reference

### 2.1 Class-Level Annotations

| Annotation | Purpose | Required? |
|---|---|---|
| `@Entity` | Marks the class as a JPA entity | ✅ Yes |
| `@Table(name="...")` | Specifies the table name | Optional |
| `@Data` *(Lombok)* | Generates getters, setters, equals, hashCode, toString | Optional |
| `@NoArgsConstructor` *(Lombok)* | Generates a no-arg constructor | Recommended |
| `@AllArgsConstructor` *(Lombok)* | Generates a constructor with all fields | Optional |

### 2.2 Field-Level Annotations

| Annotation | Purpose |
|---|---|
| `@Id` | Marks the primary key field |
| `@GeneratedValue(strategy = GenerationType.IDENTITY)` | Auto-increments the PK |
| `@Column(name="...", nullable=false, length=100)` | Maps to a specific column with constraints |
| `@OneToMany(mappedBy="...", fetch=FetchType.LAZY, cascade=CascadeType.ALL)` | Defines the "one" side of the relationship |
| `@ManyToOne` | Defines the "many" side of the relationship |
| `@JoinColumn(name="categorie_id")` | Specifies the FK column name |

---

## 3. Practical Implementation

### 3.1 The `Categorie` Entity

```java
package ma.projet.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Categorie {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nomCategorie;

    @OneToMany(mappedBy = "categorie", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JsonIgnore          // ← Prevents JSON infinite loop
    @ToString.Exclude    // ← Prevents toString() infinite loop
    private List<Produit> produits;
}
```

**Key decisions explained:**
- `mappedBy = "categorie"` — refers to the field name in `Produit` that owns the relationship
- `fetch = FetchType.LAZY` — products are NOT loaded when you load a category (better performance)
- `cascade = CascadeType.ALL` — operations (save, delete) on Categorie cascade to its Produits
- `@JsonIgnore` — prevents REST API from serializing the list and creating circular references

### 3.2 The `Produit` Entity

```java
package ma.projet.entities;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Produit {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String designation;
    private double prix;
    private int quantite;

    @ManyToOne
    @JoinColumn(name = "categorie_id")  // ← FK column in the "produit" table
    private Categorie categorie;
}
```

**Key decisions explained:**
- `@ManyToOne` — this is the "owning" side of the relationship
- `@JoinColumn(name = "categorie_id")` — the physical foreign key column is named `categorie_id`

---

## 4. Database Schema Generated

The above entities generate this SQL schema:

```sql
-- Table for Categorie
CREATE TABLE categorie (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    nom_categorie VARCHAR(255)
);

-- Table for Produit (holds the FK)
CREATE TABLE produit (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    designation  VARCHAR(255),
    prix         DOUBLE,
    quantite     INT,
    categorie_id BIGINT,                         -- Foreign Key
    FOREIGN KEY (categorie_id) REFERENCES categorie(id)
);
```

> 💡 **Key Rule**: The **foreign key always lives in the table of the "many" side** (Produit in this case).

---

## 5. Relationship Types Overview

```
OneToMany   (1:N)  →  Categorie → List<Produit>
ManyToOne   (N:1)  →  Produit → Categorie        (owning side)
OneToOne    (1:1)  →  e.g., User → UserProfile
ManyToMany  (N:M)  →  e.g., Student → List<Course>
```

### 5.1 Fetch Types

| Type | Behavior | Use When |
|------|----------|----------|
| `LAZY` | Related data is loaded **on demand** (default for collections) | Default best practice for collections |
| `EAGER` | Related data is loaded **immediately** with the parent | Use sparingly; can cause N+1 problems |

### 5.2 Cascade Types

| Type | Effect |
|------|--------|
| `CascadeType.PERSIST` | Save parent → save children |
| `CascadeType.MERGE` | Update parent → update children |
| `CascadeType.REMOVE` | Delete parent → delete children |
| `CascadeType.ALL` | All of the above |
| `CascadeType.DETACH` | Detach parent → detach children |

---

## 6. Best Practices

### ✅ Do This

```java
// Always exclude the collection from toString to avoid infinite loops
@ToString.Exclude
@OneToMany(mappedBy = "categorie")
private List<Produit> produits;

// Use LAZY loading for collections
@OneToMany(fetch = FetchType.LAZY)
private List<Produit> produits;

// Use @JsonIgnore to prevent circular JSON serialization
@JsonIgnore
@OneToMany(mappedBy = "categorie")
private List<Produit> produits;
```

### ❌ Avoid This

```java
// ❌ WRONG: No @JsonIgnore on bidirectional relationship → StackOverflowError
@OneToMany(mappedBy = "categorie")
private List<Produit> produits;  // Will cause infinite JSON loop!

// ❌ WRONG: EAGER loading on large collections → performance issues
@OneToMany(fetch = FetchType.EAGER)
private List<Produit> produits;  // Loads ALL products every time!

// ❌ WRONG: Missing mappedBy → JPA creates an unnecessary join table
@OneToMany  // Missing mappedBy!
private List<Produit> produits;
```

---

## 7. Common Mistakes to Avoid

| Mistake | Consequence | Fix |
|---------|-------------|-----|
| Forgetting `@JsonIgnore` on bidirectional relation | `StackOverflowError` when serializing to JSON | Add `@JsonIgnore` on the collection side |
| Forgetting `@ToString.Exclude` | `StackOverflowError` when calling `toString()` | Add `@ToString.Exclude` on the collection |
| Missing `mappedBy` | JPA creates an extra join table | Always specify `mappedBy` on the "one" side |
| Using `EAGER` on large collections | Slow queries / OutOfMemoryError | Use `LAZY` by default |
| Missing no-arg constructor | JPA cannot instantiate the entity | Use `@NoArgsConstructor` or add it manually |
| Forgetting `@Entity` | Class is not recognized by JPA | Always annotate domain classes with `@Entity` |

---

## 8. Review Questions

1. What is the difference between the **owning side** and the **inverse side** of a relationship in JPA?

2. In a OneToMany/ManyToOne relationship, which entity holds the **foreign key** in the database? Why?

3. What would happen if you removed `@JsonIgnore` from the `Categorie.produits` field when returning a `Categorie` from a REST API?

4. What does `mappedBy = "categorie"` mean in the `@OneToMany` annotation?

5. Explain the difference between `FetchType.LAZY` and `FetchType.EAGER`. When would you use each?

6. What is the purpose of `CascadeType.ALL`? Give an example of when it would be useful.

7. How does Spring Boot (with Hibernate) create the database schema from your entity classes?

8. Why does JPA require a **no-argument constructor** on entity classes?

---

## 9. Practice Exercises

### Exercise 1 — Create a New Entity
Create a `Fournisseur` (Supplier) entity with fields: `id`, `nom`, `telephone`, `email`. 
Add a ManyToMany relationship between `Fournisseur` and `Produit`.

### Exercise 2 — Modify the Relationship
Change the `Categorie`→`Produit` relationship so that deleting a category **does NOT** delete its products (set `categorie_id` to `NULL` instead). Which cascade type and nullable setting would you use?

### Exercise 3 — Add Validation
Add Bean Validation annotations (`@NotNull`, `@Size`, `@Min`) to both entities to enforce that:
- `nomCategorie` must not be blank and must be between 3 and 50 characters
- `prix` must be greater than 0
- `quantite` must be >= 0

---

## 10. Summary

| Concept | Key Takeaway |
|---------|-------------|
| `@Entity` | Makes a Java class persist in the database |
| `@Id` + `@GeneratedValue` | Defines auto-incremented primary key |
| `@OneToMany` | Declares the "one" side of the relationship |
| `@ManyToOne` + `@JoinColumn` | Declares the "many" side (FK owner) |
| `mappedBy` | Points to the field in the owning entity that holds the FK |
| `FetchType.LAZY` | Best practice for collections — load on demand |
| `@JsonIgnore` | Breaks JSON serialization infinite cycles |
| `@ToString.Exclude` | Breaks toString() infinite cycles |

---

## ➡️ Next Section

**[RESUME-02 → Repositories & Queries](./RESUME-02-Repositories-and-Queries.md)**  
Learn how Spring Data JPA repositories eliminate boilerplate DAO code, and how to write your first custom queries.

---

*📑 Back to [Index](./INDEX-Resumes.md)*
