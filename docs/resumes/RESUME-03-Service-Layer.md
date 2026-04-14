# 📘 RESUME 03 — Service Layer Architecture

> **Course**: LAB-2 — Spring Data JPA: Relations OneToMany & Advanced JPQL Queries  
> **Section**: 3 of 6  
> **Topic**: Service Interface Pattern, Business Logic, Spring Dependency Injection

---

## ✅ Learning Objectives Checklist

By the end of this section, you should be able to:

- [ ] Explain why the service layer is necessary in a Spring application
- [ ] Design a service **interface** with clearly defined business methods
- [ ] Implement the interface with `@Service` annotated class
- [ ] Inject repositories into services using constructor injection or `@Autowired`
- [ ] Understand the difference between the Controller, Service, and Repository layers
- [ ] Use `@Transactional` where appropriate
- [ ] Design cohesive service methods that encapsulate business logic
- [ ] Apply the **Interface Segregation** principle to service design
- [ ] Handle exceptions appropriately in the service layer

---

## 1. Core Concepts

### 1.1 The Three-Layer Architecture

A well-structured Spring application separates concerns into three distinct layers:

```
┌────────────────────────────────────────────────┐
│            Presentation Layer                  │
│    Controller / CommandLineRunner / REST API   │
│    (receives input, displays output)           │
└──────────────────────┬─────────────────────────┘
                       │ calls (via interface)
┌──────────────────────▼─────────────────────────┐
│              Service Layer                     │
│    Business logic, validation, transactions    │
│    (what the app does)                         │
└──────────────────────┬─────────────────────────┘
                       │ calls
┌──────────────────────▼─────────────────────────┐
│           Repository Layer                     │
│    Data access, queries, CRUD operations       │
│    (how data is stored/retrieved)              │
└────────────────────────────────────────────────┘
```

### 1.2 Why Use a Service Interface?

| Without Interface | With Interface |
|-------------------|----------------|
| Service class directly referenced | Controller depends only on the interface |
| Tightly coupled | Loosely coupled |
| Hard to test (can't mock easily) | Easy to mock in unit tests |
| Hard to swap implementations | Can have multiple implementations (e.g., mock, real) |
| Violates Dependency Inversion Principle | Follows DIP and SOLID principles |

---

## 2. Designing the Service Interface

### 2.1 ICategorieService

```java
package ma.projet.services;

import ma.projet.entities.Categorie;
import java.util.List;
import java.util.Optional;

public interface ICategorieService {

    // Create / Update
    Categorie saveCategorie(Categorie categorie);

    // Read
    List<Categorie> getAllCategories();
    Optional<Categorie> getCategorieById(Long id);
    Categorie getCategorieByNom(String nom);

    // Delete
    void deleteCategorie(Long id);

    // Business-specific
    boolean categorieExists(String nom);
}
```

### 2.2 IProduitService

```java
package ma.projet.services;

import ma.projet.entities.Produit;
import java.util.List;
import java.util.Optional;

public interface IProduitService {

    // Create / Update
    Produit saveProduit(Produit produit);

    // Read
    List<Produit> getAllProduits();
    Optional<Produit> getProduitById(Long id);

    // Filtered queries
    List<Produit> getProduitsByDesignation(String keyword);
    List<Produit> getProduitsByPrixRange(double min, double max);
    List<Produit> getProduitsByCategorie(String nomCategorie);
    List<Produit> getProduitsByPrixAndCategorie(double maxPrix, String nomCategorie);

    // Delete
    void deleteProduit(Long id);
}
```

> 💡 **Design Rule**: The interface defines the **contract** — what operations are available. The implementation defines **how** they work.

---

## 3. Implementing the Service

### 3.1 CategorieServiceImpl

```java
package ma.projet.services;

import lombok.RequiredArgsConstructor;
import ma.projet.entities.Categorie;
import ma.projet.repositories.CategorieRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor   // ← Lombok: generates constructor for final fields
public class CategorieServiceImpl implements ICategorieService {

    private final CategorieRepository categorieRepository;  // ← Injected via constructor

    @Override
    @Transactional
    public Categorie saveCategorie(Categorie categorie) {
        return categorieRepository.save(categorie);
    }

    @Override
    public List<Categorie> getAllCategories() {
        return categorieRepository.findAll();
    }

    @Override
    public Optional<Categorie> getCategorieById(Long id) {
        return categorieRepository.findById(id);
    }

    @Override
    public Categorie getCategorieByNom(String nom) {
        return categorieRepository.findByNomCategorie(nom)
            .orElseThrow(() -> new RuntimeException("Categorie introuvable: " + nom));
    }

    @Override
    @Transactional
    public void deleteCategorie(Long id) {
        categorieRepository.deleteById(id);
    }

    @Override
    public boolean categorieExists(String nom) {
        return categorieRepository.existsByNomCategorie(nom);
    }
}
```

### 3.2 ProduitServiceImpl

```java
package ma.projet.services;

import lombok.RequiredArgsConstructor;
import ma.projet.entities.Produit;
import ma.projet.repositories.ProduitRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ProduitServiceImpl implements IProduitService {

    private final ProduitRepository produitRepository;

    @Override
    @Transactional
    public Produit saveProduit(Produit produit) {
        return produitRepository.save(produit);
    }

    @Override
    public List<Produit> getAllProduits() {
        return produitRepository.findAll();
    }

    @Override
    public Optional<Produit> getProduitById(Long id) {
        return produitRepository.findById(id);
    }

    @Override
    public List<Produit> getProduitsByDesignation(String keyword) {
        return produitRepository.findByDesignationContaining(keyword);
    }

    @Override
    public List<Produit> getProduitsByPrixRange(double min, double max) {
        return produitRepository.findByPrixBetween(min, max);
    }

    @Override
    public List<Produit> getProduitsByCategorie(String nomCategorie) {
        return produitRepository.findByCategorieNomCategorie(nomCategorie);
    }

    @Override
    public List<Produit> getProduitsByPrixAndCategorie(double maxPrix, String nomCategorie) {
        return produitRepository.findByPrixLessThanEqualAndCategorieNomCategorie(maxPrix, nomCategorie);
    }

    @Override
    @Transactional
    public void deleteProduit(Long id) {
        produitRepository.deleteById(id);
    }
}
```

---

## 4. Dependency Injection in Spring

### 4.1 Three Ways to Inject Dependencies

```java
// ✅ Method 1: Constructor Injection (RECOMMENDED)
@Service
public class ProduitServiceImpl implements IProduitService {
    private final ProduitRepository produitRepository;

    // Spring calls this constructor automatically
    public ProduitServiceImpl(ProduitRepository produitRepository) {
        this.produitRepository = produitRepository;
    }
}

// ✅ Method 2: @RequiredArgsConstructor (Lombok shortcut for constructor injection)
@Service
@RequiredArgsConstructor
public class ProduitServiceImpl implements IProduitService {
    private final ProduitRepository produitRepository; // final = required
}

// ⚠️ Method 3: Field Injection (works, but not recommended)
@Service
public class ProduitServiceImpl implements IProduitService {
    @Autowired
    private ProduitRepository produitRepository; // ← not final, harder to test
}
```

### 4.2 Why Constructor Injection is Preferred

| Constructor Injection | Field Injection |
|-----------------------|-----------------|
| Dependencies are explicit | Dependencies are hidden |
| Works in tests without Spring | Requires Spring context to run |
| Can use `final` fields | Cannot use `final` |
| Immutable after construction | Can be changed at any time |
| Prevents circular dependencies | May allow circular dependencies |

---

## 5. The @Service Annotation

```java
@Service  // ← Marks this class as a Spring-managed bean in the Service layer
public class ProduitServiceImpl implements IProduitService {
    // ...
}
```

When Spring scans the application, it finds `@Service`-annotated classes and registers them in the **Application Context** (Spring's IoC container). When another class needs an `IProduitService`, Spring provides the `ProduitServiceImpl` instance automatically.

```
Application starts
      │
      ▼
Spring scans @Service, @Repository, @Controller
      │
      ▼
Creates beans and injects dependencies
      │
      ▼
Application ready — you can use @Autowired / constructor injection
```

---

## 6. @Transactional Explained

```java
@Transactional
public Produit saveProduit(Produit produit) {
    // Everything in this method runs in a single DB transaction
    // If any exception is thrown, the transaction is ROLLED BACK
    return produitRepository.save(produit);
}
```

### When to Use @Transactional

| Scenario | Use @Transactional? |
|----------|---------------------|
| Reading data | Optional (read-only = true for optimization) |
| Writing / modifying data | ✅ Yes |
| Multiple DB operations that must succeed together | ✅ Yes (essential) |
| Single save/delete operation | Optional (repositories are already transactional) |

```java
// Example: Multiple operations that must succeed or fail together
@Transactional
public void transferStock(Long fromId, Long toId, int quantity) {
    Produit from = getProduitById(fromId).orElseThrow(...);
    Produit to = getProduitById(toId).orElseThrow(...);
    
    from.setQuantite(from.getQuantite() - quantity); // Step 1
    to.setQuantite(to.getQuantite() + quantity);     // Step 2
    
    produitRepository.save(from);  // If this fails,
    produitRepository.save(to);    // this won't execute, and both are rolled back
}
```

---

## 7. Using Services from the Presentation Layer

### 7.1 From a CommandLineRunner

```java
@SpringBootApplication
public class MyApplication implements CommandLineRunner {

    @Autowired
    private IProduitService produitService;

    @Autowired
    private ICategorieService categorieService;

    @Override
    public void run(String... args) throws Exception {
        // Create a category
        Categorie cat = new Categorie(null, "Electronique", null);
        categorieService.saveCategorie(cat);

        // Create a product linked to the category
        Produit p = new Produit(null, "Laptop", 1200.0, 10, cat);
        produitService.saveProduit(p);

        // Display all products
        produitService.getAllProduits().forEach(System.out::println);
    }
}
```

### 7.2 From a REST Controller (Future Pattern)

```java
@RestController
@RequestMapping("/api/produits")
@RequiredArgsConstructor
public class ProduitController {

    private final IProduitService produitService; // ← Injected interface, not implementation

    @GetMapping
    public List<Produit> getAll() {
        return produitService.getAllProduits();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Produit> getById(@PathVariable Long id) {
        return produitService.getProduitById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
}
```

---

## 8. Best Practices

### ✅ Do This

```java
// ✅ Depend on the interface, not the implementation
private final IProduitService produitService;   // GOOD

// ✅ Use @RequiredArgsConstructor for clean constructor injection
@Service
@RequiredArgsConstructor
public class ProduitServiceImpl implements IProduitService {
    private final ProduitRepository produitRepository;
}

// ✅ Keep service methods cohesive (one purpose per method)
public List<Produit> getProduitsByPrixRange(double min, double max) { ... }
public List<Produit> getProduitsByCategorie(String nom) { ... }

// ✅ Throw meaningful exceptions
public Produit getProduitById(Long id) {
    return produitRepository.findById(id)
        .orElseThrow(() -> new EntityNotFoundException("Produit #" + id + " not found"));
}
```

### ❌ Avoid This

```java
// ❌ Don't put business logic in controllers
@GetMapping
public List<Produit> getAll() {
    return produitRepository.findAll(); // ← Skip the service layer — BAD!
}

// ❌ Don't put DB queries directly in the service class
@Service
public class ProduitServiceImpl {
    @PersistenceContext
    private EntityManager em;
    
    public List<Produit> getAll() {
        return em.createQuery("SELECT p FROM Produit p").getResultList(); // ← Use repository instead!
    }
}

// ❌ Don't expose the implementation class as the type
private final ProduitServiceImpl produitService; // ← WRONG: depends on implementation
```

---

## 9. Common Mistakes to Avoid

| Mistake | Consequence | Fix |
|---------|-------------|-----|
| Injecting the implementation class directly | Tight coupling, breaks tests | Inject the interface |
| Forgetting `@Service` | Spring won't create the bean, `NoSuchBeanDefinitionException` | Always add `@Service` |
| Business logic in repository layer | Violates separation of concerns | Move to service layer |
| Skipping service layer, calling repository from controller | Hard to test, add business logic later | Always use service layer |
| Not using `@Transactional` for multi-step DB operations | Partial updates can corrupt data | Add `@Transactional` on write methods |

---

## 10. Review Questions

1. Why do we create a service **interface** instead of just using the service **class** directly?

2. What is the purpose of `@Service` annotation? What happens if you forget it?

3. Compare constructor injection vs field injection (`@Autowired` on field). Why is constructor injection preferred?

4. What does `@RequiredArgsConstructor` (Lombok) do? How does it relate to constructor injection?

5. When should you use `@Transactional`? Give an example where forgetting it could cause data corruption.

6. A product has a complex pricing rule: if quantity > 100, apply a 10% discount. Where should this logic live — in the controller, service, or repository? Why?

7. How does Spring know which implementation to inject when you have an interface `IProduitService`? What if you had two implementations?

8. What is the difference between the Service layer and the Repository layer in terms of responsibility?

---

## 11. Practice Exercises

### Exercise 1 — Extend the Service Interface
Add the following methods to `IProduitService` and implement them:
- `getProduitsEnRupture()` — returns all products where `quantite == 0`
- `getTopProduitsByCategorie(String nom, int limit)` — returns top N most expensive products in a category

### Exercise 2 — Add Business Validation
In `saveProduit()`, add validation:
- Throw `IllegalArgumentException` if `prix <= 0`
- Throw `IllegalArgumentException` if `quantite < 0`
- Throw `IllegalArgumentException` if `designation` is null or blank

### Exercise 3 — Service Layer Test
Write a unit test for `ProduitServiceImpl.getProduitsByPrixRange()` by mocking `ProduitRepository`. Verify that the service correctly delegates to the repository.

---

## 12. Summary

| Concept | Key Takeaway |
|---------|-------------|
| Three-layer architecture | Controller → Service → Repository — each has one responsibility |
| Service interface | Defines the contract; promotes loose coupling and testability |
| `@Service` | Marks a class as a Spring-managed bean in the service layer |
| Constructor injection | Preferred over `@Autowired` field injection |
| `@RequiredArgsConstructor` | Lombok shortcut for constructor injection of `final` fields |
| `@Transactional` | Ensures DB operations are atomic — all succeed or all fail |

---

## ➡️ Next Section

**[RESUME-04 → Advanced Queries & Filtering](./RESUME-04-Advanced-Queries.md)**  
Master complex JPQL queries with multiple conditions, dynamic filtering, and sorting.

---

*📑 Back to [Index](./INDEX-Resumes.md)*
