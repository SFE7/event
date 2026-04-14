# 📘 RESUME 06 — Building the Complete Application

> **Course**: LAB-2 — Spring Data JPA: Relations OneToMany & Advanced JPQL Queries  
> **Section**: 6 of 6  
> **Topic**: Complete Application Integration, Data Initialization, CommandLineRunner

---

## ✅ Learning Objectives Checklist

By the end of this section, you should be able to:

- [ ] Structure a complete Spring Boot project with all layers (Entity, Repository, Service, Main)
- [ ] Use `CommandLineRunner` to initialize test data and display results at startup
- [ ] Implement `ApplicationRunner` as an alternative to `CommandLineRunner`
- [ ] Wire all components together using Spring's dependency injection
- [ ] Initialize related entities (Categories + Products) maintaining referential integrity
- [ ] Display formatted output from service queries in the console
- [ ] Understand the Spring Boot auto-configuration for JPA
- [ ] Configure `application.properties` for database and JPA settings
- [ ] Use `spring.jpa.hibernate.ddl-auto` to control schema creation
- [ ] Debug common Spring Boot startup issues

---

## 1. Complete Project Structure

```
src/
└── main/
    ├── java/
    │   └── ma/projet/
    │       ├── MyApplication.java          ← Main + CommandLineRunner
    │       ├── entities/
    │       │   ├── Categorie.java
    │       │   └── Produit.java
    │       ├── repositories/
    │       │   ├── CategorieRepository.java
    │       │   └── ProduitRepository.java
    │       └── services/
    │           ├── ICategorieService.java
    │           ├── IProduitService.java
    │           ├── CategorieServiceImpl.java
    │           └── ProduitServiceImpl.java
    └── resources/
        └── application.properties          ← DB and JPA configuration
```

---

## 2. Application Configuration

### 2.1 application.properties

```properties
# ───────────────────────────────────────────────
# Database Connection
# ───────────────────────────────────────────────
spring.datasource.url=jdbc:mysql://localhost:3306/lab2_db?createDatabaseIfNotExist=true
spring.datasource.username=root
spring.datasource.password=yourpassword
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# ───────────────────────────────────────────────
# JPA / Hibernate Configuration
# ───────────────────────────────────────────────
spring.jpa.hibernate.ddl-auto=create       # create|update|validate|none
spring.jpa.show-sql=true                   # Print SQL in console
spring.jpa.properties.hibernate.format_sql=true   # Format SQL output
spring.jpa.database-platform=org.hibernate.dialect.MySQL8Dialect
```

### 2.2 DDL-Auto Options Explained

| Value | Behavior | Use When |
|-------|----------|----------|
| `create` | **Drops and recreates** tables on every startup | Development (fresh data each time) |
| `create-drop` | Creates tables on startup, drops on shutdown | Testing |
| `update` | **Adds new columns** but doesn't drop existing | Development (keep data) |
| `validate` | Validates schema but makes no changes | Production (fail fast if schema wrong) |
| `none` | Does nothing | Production (manage schema externally) |

> ⚠️ **WARNING**: Never use `create` or `create-drop` in production — it DELETES ALL DATA on restart!

### 2.3 Maven Dependencies (pom.xml)

```xml
<dependencies>
    <!-- Spring Data JPA -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>

    <!-- MySQL Driver -->
    <dependency>
        <groupId>com.mysql</groupId>
        <artifactId>mysql-connector-j</artifactId>
        <scope>runtime</scope>
    </dependency>

    <!-- Lombok (code generation) -->
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>

    <!-- Spring Web (for REST APIs) -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>

    <!-- Spring Boot Test -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

---

## 3. The Main Application Class

### 3.1 CommandLineRunner Pattern

```java
package ma.projet;

import ma.projet.entities.Categorie;
import ma.projet.entities.Produit;
import ma.projet.services.ICategorieService;
import ma.projet.services.IProduitService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.util.List;

@SpringBootApplication
public class MyApplication implements CommandLineRunner {

    @Autowired
    private ICategorieService categorieService;

    @Autowired
    private IProduitService produitService;

    public static void main(String[] args) {
        SpringApplication.run(MyApplication.class, args);
    }

    @Override
    public void run(String... args) throws Exception {
        initData();
        displayResults();
    }

    // ─────────────────────────────────────────────────────────
    // DATA INITIALIZATION
    // ─────────────────────────────────────────────────────────
    private void initData() {
        System.out.println("\n===== Initializing Data =====");

        // 1. Create categories
        Categorie electronique = categorieService.saveCategorie(
            new Categorie(null, "Electronique", null)
        );
        Categorie informatique = categorieService.saveCategorie(
            new Categorie(null, "Informatique", null)
        );
        Categorie mobilier = categorieService.saveCategorie(
            new Categorie(null, "Mobilier", null)
        );

        System.out.println("Categories created: " + categorieService.getAllCategories().size());

        // 2. Create products linked to categories
        produitService.saveProduit(new Produit(null, "Samsung Galaxy S23", 1200.0, 15, electronique));
        produitService.saveProduit(new Produit(null, "iPhone 15 Pro",      1800.0, 8,  electronique));
        produitService.saveProduit(new Produit(null, "Sony WH-1000XM5",    380.0,  30, electronique));

        produitService.saveProduit(new Produit(null, "Laptop HP ProBook",  950.0,  12, informatique));
        produitService.saveProduit(new Produit(null, "Laptop Dell XPS",    1500.0, 5,  informatique));
        produitService.saveProduit(new Produit(null, "Clavier Mécanique",  120.0,  50, informatique));
        produitService.saveProduit(new Produit(null, "Souris Logitech",    60.0,   100, informatique));

        produitService.saveProduit(new Produit(null, "Bureau en Bois",     350.0,  20, mobilier));
        produitService.saveProduit(new Produit(null, "Chaise Ergonomique", 280.0,  35, mobilier));

        System.out.println("Products created: " + produitService.getAllProduits().size());
    }

    // ─────────────────────────────────────────────────────────
    // DISPLAY RESULTS
    // ─────────────────────────────────────────────────────────
    private void displayResults() {
        // 1. Display all products
        System.out.println("\n===== All Products =====");
        produitService.getAllProduits().forEach(p ->
            System.out.printf("  [%d] %-30s  %.2f DH  (qty: %d)  [%s]%n",
                p.getId(),
                p.getDesignation(),
                p.getPrix(),
                p.getQuantite(),
                p.getCategorie().getNomCategorie())
        );

        // 2. Products by price range
        System.out.println("\n===== Products (100 DH - 500 DH) =====");
        produitService.getProduitsByPrixRange(100.0, 500.0).forEach(p ->
            System.out.printf("  %-30s  %.2f DH%n", p.getDesignation(), p.getPrix())
        );

        // 3. Products by category
        System.out.println("\n===== Informatique Products =====");
        produitService.getProduitsByCategorie("Informatique").forEach(p ->
            System.out.printf("  %-30s  %.2f DH%n", p.getDesignation(), p.getPrix())
        );

        // 4. Products by keyword
        System.out.println("\n===== Products containing 'Laptop' =====");
        produitService.getProduitsByDesignation("Laptop").forEach(p ->
            System.out.printf("  %-30s  %.2f DH%n", p.getDesignation(), p.getPrix())
        );

        // 5. Products by max price and category
        System.out.println("\n===== Electronique products <= 1200 DH =====");
        produitService.getProduitsByPrixAndCategorie(1200.0, "Electronique").forEach(p ->
            System.out.printf("  %-30s  %.2f DH%n", p.getDesignation(), p.getPrix())
        );
    }
}
```

### 3.2 Expected Console Output

```
===== Initializing Data =====
Categories created: 3
Products created: 9

===== All Products =====
  [1] Samsung Galaxy S23             1200.00 DH  (qty: 15)  [Electronique]
  [2] iPhone 15 Pro                  1800.00 DH  (qty: 8)   [Electronique]
  [3] Sony WH-1000XM5                 380.00 DH  (qty: 30)  [Electronique]
  [4] Laptop HP ProBook               950.00 DH  (qty: 12)  [Informatique]
  ...

===== Products (100 DH - 500 DH) =====
  Sony WH-1000XM5                    380.00 DH
  Clavier Mécanique                  120.00 DH
  Bureau en Bois                     350.00 DH
  Chaise Ergonomique                 280.00 DH

===== Informatique Products =====
  Laptop HP ProBook                  950.00 DH
  Laptop Dell XPS                   1500.00 DH
  Clavier Mécanique                  120.00 DH
  Souris Logitech                     60.00 DH

===== Products containing 'Laptop' =====
  Laptop HP ProBook                  950.00 DH
  Laptop Dell XPS                   1500.00 DH

===== Electronique products <= 1200 DH =====
  Samsung Galaxy S23                1200.00 DH
  Sony WH-1000XM5                    380.00 DH
```

---

## 4. Alternative: @Bean CommandLineRunner

If you prefer not to implement the interface on the main class:

```java
@SpringBootApplication
public class MyApplication {

    public static void main(String[] args) {
        SpringApplication.run(MyApplication.class, args);
    }

    @Bean
    CommandLineRunner init(ICategorieService catService, IProduitService prodService) {
        return args -> {
            // initialization code here
            Categorie c = catService.saveCategorie(new Categorie(null, "Electronics", null));
            prodService.saveProduit(new Produit(null, "TV", 500.0, 10, c));
            prodService.getAllProduits().forEach(System.out::println);
        };
    }
}
```

---

## 5. Spring Boot Auto-Configuration Flow

```
Application starts (@SpringBootApplication)
    │
    ├── @ComponentScan → finds @Entity, @Repository, @Service, @Controller
    │
    ├── @EnableAutoConfiguration
    │       │
    │       ├── Detects mysql-connector on classpath → configures DataSource
    │       │
    │       ├── Detects spring-data-jpa → configures EntityManagerFactory
    │       │
    │       └── Reads application.properties for config values
    │
    ├── Spring Data JPA generates Repository implementations
    │
    ├── Spring creates all @Service, @Repository beans
    │
    ├── Injects dependencies (constructor injection)
    │
    └── Calls CommandLineRunner.run() ← your code executes here
```

---

## 6. Data Initialization Best Practices

### 6.1 Order of Operations (Important!)

```java
// ✅ CORRECT: Create categories BEFORE products
Categorie cat = categorieService.saveCategorie(new Categorie(null, "Electronics", null));
Produit p = produitService.saveProduit(new Produit(null, "TV", 500.0, 10, cat));
// cat must exist in DB before p is saved (FK constraint)

// ❌ WRONG: Creating product with unsaved category
Categorie cat = new Categorie(null, "Electronics", null); // NOT saved!
Produit p = new Produit(null, "TV", 500.0, 10, cat);
produitService.saveProduit(p); // FK violation if cascading not enabled!
```

### 6.2 Checking for Existing Data

```java
@Override
public void run(String... args) throws Exception {
    // Only initialize if database is empty (idempotent initialization)
    if (categorieService.getAllCategories().isEmpty()) {
        initData();
    }
    displayResults();
}
```

### 6.3 Using data.sql for Test Data

Alternative to CommandLineRunner: place a `src/main/resources/data.sql` file:

```sql
-- data.sql (executed automatically by Spring Boot)
INSERT INTO categorie (nom_categorie) VALUES ('Electronique');
INSERT INTO categorie (nom_categorie) VALUES ('Informatique');

INSERT INTO produit (designation, prix, quantite, categorie_id) 
VALUES ('Laptop HP', 950.00, 10, 2);
```

```properties
# Enable data.sql execution
spring.sql.init.mode=always
spring.jpa.defer-datasource-initialization=true
```

---

## 7. Formatting Output

### 7.1 printf Formatting

```java
// Column-aligned output
System.out.printf("%-5d %-30s %10.2f DH %5d units%n",
    p.getId(),          // left-aligned, 5 chars
    p.getDesignation(), // left-aligned, 30 chars
    p.getPrix(),        // right-aligned, 10 chars, 2 decimal places
    p.getQuantite()     // right-aligned, 5 chars
);
```

### 7.2 Table Output with Separators

```java
private void printSeparator() {
    System.out.println("─".repeat(70));
}

private void printHeader() {
    printSeparator();
    System.out.printf("%-5s %-30s %10s %8s %-15s%n",
        "ID", "Designation", "Prix (DH)", "Quantite", "Categorie");
    printSeparator();
}

private void printProduit(Produit p) {
    System.out.printf("%-5d %-30s %10.2f %8d %-15s%n",
        p.getId(),
        p.getDesignation(),
        p.getPrix(),
        p.getQuantite(),
        p.getCategorie() != null ? p.getCategorie().getNomCategorie() : "N/A"
    );
}
```

---

## 8. Common Runtime Issues and Solutions

### 8.1 Database Connection Issues

```
Error: Could not create connection to database server
```
**Fix**: Verify MySQL is running, check host/port/credentials in `application.properties`.

### 8.2 Entity Not Found

```
Error: Unknown entity: ma.projet.entities.Produit
```
**Fix**: Ensure `@Entity` annotation is present on the class and the package is scanned.

### 8.3 FK Constraint Violation

```
Error: Cannot add or update a child row: a foreign key constraint fails
```
**Fix**: Save the parent entity (Categorie) before the child (Produit), or use `CascadeType.PERSIST`.

### 8.4 LazyInitializationException

```
Error: org.hibernate.LazyInitializationException: could not initialize proxy
```
**Fix**: Access lazy collections within a transaction, or use `JOIN FETCH` in your query, or use `@Transactional`.

### 8.5 StackOverflowError on toString/JSON

```
Error: java.lang.StackOverflowError
```
**Fix**: Add `@ToString.Exclude` to the collection field in the entity, and/or `@JsonIgnore`.

---

## 9. Complete End-to-End Flow

```
User Starts Application
        │
        ▼
  SpringApplication.run()
        │
        ▼
  Spring Context Initialized
  (All beans created and injected)
        │
        ▼
  CommandLineRunner.run() called
        │
        ├── initData()
        │     │
        │     ├── categorieService.saveCategorie(...)
        │     │     └── categorieRepository.save(...)
        │     │           └── INSERT INTO categorie ...
        │     │
        │     └── produitService.saveProduit(...)
        │           └── produitRepository.save(...)
        │                 └── INSERT INTO produit ...
        │
        └── displayResults()
              │
              ├── produitService.getAllProduits()
              │     └── produitRepository.findAll()
              │           └── SELECT * FROM produit JOIN categorie ...
              │
              └── System.out.printf(...)
                    └── Output to console
```

---

## 10. Best Practices for Application Structure

### ✅ Do This

```java
// ✅ Keep initData() and displayResults() in separate methods
private void initData() { ... }
private void displayResults() { ... }

// ✅ Check for empty DB to avoid duplicates on restart
if (produitService.getAllProduits().isEmpty()) {
    initData();
}

// ✅ Use formatted output for readability
System.out.printf("%-30s %10.2f DH%n", p.getDesignation(), p.getPrix());

// ✅ Use meaningful variable names for created entities
Categorie informatique = categorieService.saveCategorie(...);
// Then use 'informatique' when creating its products
```

### ❌ Avoid This

```java
// ❌ Don't mix initialization and display in one big run() method
@Override
public void run(String... args) {
    // 100+ lines of mixed init and display code
}

// ❌ Don't create entities with hardcoded IDs
new Categorie(1L, "Electronics", null); // ID should be null for new entities!

// ❌ Don't save products before their categories
produitService.saveProduit(new Produit(null, "TV", 500.0, 10, unsavedCategorie));
```

---

## 11. Review Questions

1. What is the purpose of `CommandLineRunner` in a Spring Boot application? When is `run()` called?

2. What is the difference between `spring.jpa.hibernate.ddl-auto=create` and `update`? When would you use each?

3. Why must you save a `Categorie` before saving a `Produit` that references it?

4. What causes `LazyInitializationException`? How do you fix it?

5. Describe the full sequence of events from application startup to your `CommandLineRunner.run()` being executed.

6. How can you prevent duplicate data from being inserted each time the application restarts?

7. What does `@SpringBootApplication` combine? What would you need to write without it?

8. Explain the three-layer flow when `produitService.saveProduit(p)` is called from `CommandLineRunner`.

---

## 12. Practice Exercises

### Exercise 1 — Extended Initialization
Extend `initData()` to create 5 categories and at least 3 products per category. Ensure at least one product is in a price range of 50–200 DH.

### Exercise 2 — Enhanced Display
Add a new display method `displayStatistics()` that shows:
- Total number of products
- Average product price
- Most expensive product
- Category with the most products

### Exercise 3 — Conditional Initialization
Modify `run()` to:
1. Only initialize data if the database is empty
2. Print a message if data already exists: "Database already has X products, skipping initialization"
3. Always display results regardless

### Exercise 4 — User Input
Modify the application to accept a command-line argument:
- `--init` : initialize data
- `--display` : display all products
- `--search=laptop` : search for products by keyword

```java
@Override
public void run(String... args) throws Exception {
    for (String arg : args) {
        if (arg.equals("--init")) initData();
        else if (arg.equals("--display")) displayResults();
        else if (arg.startsWith("--search=")) {
            String keyword = arg.substring("--search=".length());
            produitService.getProduitsByDesignation(keyword).forEach(System.out::println);
        }
    }
}
```

---

## 13. Final Checklist — Complete Application

Before submitting your project, verify:

```
Entities
  □ Categorie entity with @Entity, @Id, @GeneratedValue, @OneToMany
  □ Produit entity with @Entity, @Id, @GeneratedValue, @ManyToOne, @JoinColumn
  □ @JsonIgnore and @ToString.Exclude on Categorie.produits
  □ Lombok annotations (@Data, @NoArgsConstructor, @AllArgsConstructor)

Repositories
  □ CategorieRepository extends JpaRepository<Categorie, Long>
  □ ProduitRepository extends JpaRepository<Produit, Long>
  □ At least 2 custom query methods in ProduitRepository
  □ Multi-criteria JPQL query (price + category name)

Services
  □ ICategorieService interface with CRUD methods
  □ IProduitService interface with CRUD + filter methods
  □ CategorieServiceImpl @Service with @RequiredArgsConstructor
  □ ProduitServiceImpl @Service with @RequiredArgsConstructor

Application
  □ application.properties configured correctly
  □ CommandLineRunner initializes test data
  □ Results displayed for all query types
  □ No StackOverflowError in output

Tests
  □ At least one @DataJpaTest for ProduitRepository
  □ At least one Mockito unit test for ProduitServiceImpl
  □ Tests follow AAA pattern
  □ At least one assertThrows test
```

---

## 14. Summary

| Concept | Key Takeaway |
|---------|-------------|
| `@SpringBootApplication` | Combines `@Configuration`, `@EnableAutoConfiguration`, `@ComponentScan` |
| `CommandLineRunner` | Executes code after Spring context is initialized |
| `application.properties` | Central configuration for DB connection and JPA settings |
| `ddl-auto=create` | Creates/drops schema on startup — only for development |
| Data initialization order | Always save parent (Categorie) before child (Produit) |
| `printf` formatting | Produces aligned, readable console output |
| Idempotent initialization | Check if data exists before inserting |

---

## 🎓 Course Complete!

You have now learned:

1. ✅ **Section 1** — JPA Entities and Relationships
2. ✅ **Section 2** — Spring Data Repositories
3. ✅ **Section 3** — Service Layer Architecture
4. ✅ **Section 4** — Advanced JPQL Queries
5. ✅ **Section 5** — Testing and Validation
6. ✅ **Section 6** — Complete Application Integration

**Next steps to deepen your knowledge:**
- Spring MVC REST Controllers (`@RestController`, `@GetMapping`)
- Spring Security (authentication/authorization)
- Spring Boot DevTools (hot reload)
- Docker containerization of your Spring Boot app
- Spring Cloud Microservices

---

*📑 Back to [Index](./INDEX-Resumes.md)*
