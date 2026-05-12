# 📇 INDEX — LAB-2 Spring Data JPA Course Resumes

> **Course**: LAB-2 — Spring Data JPA: Relations OneToMany & Advanced JPQL Queries  
> **Target Audience**: Students learning Spring Data JPA  
> **Format**: Multi-page summary resumes with key concepts, code examples, and exercises

---

## 📚 Quick Navigation

| # | Resume | Topic | Key Skills |
|---|--------|-------|------------|
| 01 | [Entities & Relationships](#section-1) | JPA Entities, OneToMany, ManyToOne | `@Entity`, `@OneToMany`, `@ManyToOne`, `@JoinColumn` |
| 02 | [Repositories & Queries](#section-2) | Spring Data JPA, JPQL basics | `JpaRepository`, derived methods, `@Query` |
| 03 | [Service Layer](#section-3) | Service interface, DI, transactions | `@Service`, interfaces, `@Transactional` |
| 04 | [Advanced Queries](#section-4) | Complex JPQL, filtering, sorting | `AND/OR`, `BETWEEN`, `LIKE`, aggregates |
| 05 | [Testing & Validation](#section-5) | JUnit 5, Mockito, AAA pattern | `@Test`, `@DataJpaTest`, mocking |
| 06 | [Complete Application](#section-6) | Integration, initialization | `CommandLineRunner`, `application.properties` |

---

## 📖 Resume Descriptions

---

<a name="section-1"></a>
### 📘 [RESUME-01 — Understanding Entities & Relationships](./RESUME-01-Entities-and-Relationships.md)

**What you'll learn:**
- The concept and purpose of JPA entities
- How to annotate a Java class to map it to a database table
- Designing OneToMany / ManyToOne bidirectional relationships
- Using `@JoinColumn`, `mappedBy`, `FetchType`, and `CascadeType`
- Preventing infinite loops with `@JsonIgnore` and `@ToString.Exclude`

**Core Annotations:**
```java
@Entity  @Id  @GeneratedValue  @Column
@OneToMany(mappedBy="...", fetch=FetchType.LAZY, cascade=CascadeType.ALL)
@ManyToOne  @JoinColumn(name="categorie_id")
@JsonIgnore  @ToString.Exclude
```

**Entities Covered:** `Categorie`, `Produit`

---

<a name="section-2"></a>
### 📘 [RESUME-02 — Data Access with Repositories](./RESUME-02-Repositories-and-Queries.md)

**What you'll learn:**
- The Repository pattern and its benefits
- Built-in CRUD methods from `JpaRepository`
- Creating custom queries using method naming conventions
- Writing JPQL queries with `@Query` annotation
- Named parameters, positional parameters, and `@Param`

**Key Code Pattern:**
```java
public interface ProduitRepository extends JpaRepository<Produit, Long> {
    List<Produit> findByDesignationContaining(String keyword);
    
    @Query("SELECT p FROM Produit p WHERE p.prix BETWEEN :min AND :max")
    List<Produit> findByPrixRange(@Param("min") double min, @Param("max") double max);
}
```

---

<a name="section-3"></a>
### 📘 [RESUME-03 — Service Layer Architecture](./RESUME-03-Service-Layer.md)

**What you'll learn:**
- Three-layer application architecture (Controller → Service → Repository)
- Designing service interfaces and their implementations
- Spring's dependency injection with constructor injection
- `@RequiredArgsConstructor` (Lombok) pattern
- Using `@Transactional` for atomic database operations

**Key Code Pattern:**
```java
public interface IProduitService {
    List<Produit> getAllProduits();
    Produit saveProduit(Produit produit);
}

@Service
@RequiredArgsConstructor
public class ProduitServiceImpl implements IProduitService {
    private final ProduitRepository produitRepository;
    // ...
}
```

---

<a name="section-4"></a>
### 📘 [RESUME-04 — Advanced Queries & Filtering](./RESUME-04-Advanced-Queries.md)

**What you'll learn:**
- Multi-criteria JPQL queries using `AND`, `OR`
- String matching with `LIKE` and case-insensitive search
- Range queries with `BETWEEN` and comparison operators
- `ORDER BY` for static and dynamic sorting
- Aggregate functions: `COUNT`, `MAX`, `MIN`, `AVG`, `SUM`
- `GROUP BY` and `HAVING` clauses
- `JOIN FETCH` to solve the N+1 query problem

**Key Code Pattern:**
```java
@Query("""
    SELECT p FROM Produit p 
    WHERE p.prix <= :maxPrix 
    AND p.categorie.nomCategorie = :nom
    ORDER BY p.prix ASC
    """)
List<Produit> findByPrixMaxAndCategorie(
    @Param("maxPrix") double maxPrix,
    @Param("nom") String nom
);
```

---

<a name="section-5"></a>
### 📘 [RESUME-05 — Testing & Validation](./RESUME-05-Testing-and-Validation.md)

**What you'll learn:**
- Writing tests with JUnit 5 annotations
- Applying the **AAA Pattern** (Arrange → Act → Assert)
- Repository integration tests with `@DataJpaTest`
- Service unit tests using Mockito (`@Mock`, `@InjectMocks`)
- Stubbing with `when().thenReturn()` and verifying with `verify()`
- Testing exception cases with `assertThrows`

**Key Code Pattern:**
```java
@Test
void testSaveProduit() {
    // Arrange
    Produit p = new Produit(null, "Laptop", 1200.0, 5, categorie);
    when(produitRepository.save(p)).thenReturn(new Produit(1L, "Laptop", 1200.0, 5, categorie));

    // Act
    Produit result = produitService.saveProduit(p);

    // Assert
    assertNotNull(result.getId());
    verify(produitRepository).save(p);
}
```

---

<a name="section-6"></a>
### 📘 [RESUME-06 — Building the Complete Application](./RESUME-06-Complete-Application.md)

**What you'll learn:**
- Full project structure and package organization
- Configuring `application.properties` for Spring Data JPA
- Using `CommandLineRunner` to initialize data and display results
- Understanding `ddl-auto` options (`create`, `update`, `validate`, `none`)
- The Spring Boot auto-configuration flow
- Proper data initialization order (parent before child entities)
- Formatted console output with `printf`

**Key Code Pattern:**
```java
@SpringBootApplication
public class MyApplication implements CommandLineRunner {
    @Autowired private ICategorieService categorieService;
    @Autowired private IProduitService produitService;

    @Override
    public void run(String... args) throws Exception {
        initData();
        displayResults();
    }
}
```

---

## 🗺️ Learning Path

```
START
  │
  ▼
[01] Entities & Relationships
  │   Create Categorie and Produit entities
  │   Configure OneToMany / ManyToOne
  │
  ▼
[02] Repositories & Queries
  │   Create JpaRepository interfaces
  │   Add derived query methods and @Query
  │
  ▼
[03] Service Layer Architecture
  │   Create service interfaces and implementations
  │   Apply constructor injection and @Transactional
  │
  ▼
[04] Advanced Queries & Filtering
  │   Write complex JPQL with AND/OR/LIKE/BETWEEN
  │   Use aggregates, GROUP BY, JOIN FETCH
  │
  ▼
[05] Testing & Validation
  │   Write @DataJpaTest repository tests
  │   Write Mockito service unit tests
  │
  ▼
[06] Complete Application
  │   Wire everything together with CommandLineRunner
  │   Initialize data and display formatted output
  │
  ▼
COMPLETE ✅
```

---

## 📋 Master Skills Checklist

Use this to track your progress across all sections:

### Section 1 — Entities & Relationships
- [ ] Create `@Entity` class with proper annotations
- [ ] Configure primary key with `@Id` and `@GeneratedValue`
- [ ] Implement OneToMany / ManyToOne bidirectional relationship
- [ ] Use `@JsonIgnore` and `@ToString.Exclude` to prevent infinite loops

### Section 2 — Repositories & Queries
- [ ] Create `JpaRepository` interface for each entity
- [ ] Use built-in CRUD operations (`save`, `findById`, `findAll`, `delete`)
- [ ] Write at least 3 derived query methods
- [ ] Write at least 2 `@Query` JPQL queries with named parameters

### Section 3 — Service Layer
- [ ] Design `ICategorieService` and `IProduitService` interfaces
- [ ] Implement both services with `@Service` and `@RequiredArgsConstructor`
- [ ] Inject dependencies via constructor (not field injection)
- [ ] Apply `@Transactional` on write operations

### Section 4 — Advanced Queries
- [ ] Write a multi-criteria JPQL query (price + category filter)
- [ ] Use `ORDER BY` in JPQL
- [ ] Write at least one aggregate query (`COUNT`, `AVG`, etc.)
- [ ] Understand and use `JOIN FETCH` to prevent N+1

### Section 5 — Testing
- [ ] Write at least 3 `@DataJpaTest` repository tests
- [ ] Write at least 3 Mockito service unit tests
- [ ] Every test follows the AAA pattern
- [ ] Include at least one `assertThrows` test

### Section 6 — Complete Application
- [ ] Configure `application.properties` correctly
- [ ] Implement `CommandLineRunner` with `initData()` and `displayResults()`
- [ ] Application runs without errors
- [ ] All query types are demonstrated in output

---

## 📊 Concept Dependencies Map

```
Lombok (@Data, @NoArgsConstructor)
    └── Used by: all entities

@Entity + @Id + @GeneratedValue
    └── Required by: JpaRepository

@OneToMany + @ManyToOne + @JoinColumn
    └── Enables: cross-entity queries, JOIN in JPQL

JpaRepository (CRUD)
    └── Used by: Service implementations
    └── Extended by: custom query methods

@Query + JPQL
    └── Builds on: entity field names (not DB column names)
    └── Uses: @Param for named parameters

Service Interface + @Service
    └── Injected into: Controllers, CommandLineRunner
    └── Uses: Repository methods

@Transactional
    └── Applied to: write operations in service

JUnit 5 + Mockito
    └── Tests: service layer (with mocks)
    └── @DataJpaTest: tests repository layer

CommandLineRunner
    └── Uses: service methods
    └── Demonstrates: all repository queries
```

---

## 🔗 External Resources

- [Spring Data JPA Documentation](https://docs.spring.io/spring-data/jpa/docs/current/reference/html/)
- [Hibernate ORM Documentation](https://hibernate.org/orm/documentation/)
- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)
- [Mockito Documentation](https://javadoc.io/doc/org.mockito/mockito-core/latest/index.html)
- [Spring Boot Reference Documentation](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/)
- [Baeldung Spring Data JPA Tutorial](https://www.baeldung.com/the-persistence-layer-with-spring-data-jpa)

---

*Generated for LAB-2 — Spring Data JPA Course*
