# 📘 RESUME 05 — Testing & Validation

> **Course**: LAB-2 — Spring Data JPA: Relations OneToMany & Advanced JPQL Queries  
> **Section**: 5 of 6  
> **Topic**: JUnit 5, AAA Pattern, Spring Boot Test, Assertions, Mocking

---

## ✅ Learning Objectives Checklist

By the end of this section, you should be able to:

- [ ] Explain the purpose and benefits of automated testing
- [ ] Write unit tests using **JUnit 5** (`@Test`, `@BeforeEach`, `@AfterEach`)
- [ ] Apply the **AAA pattern** (Arrange, Act, Assert) in every test
- [ ] Use `Assertions` from JUnit 5 (`assertEquals`, `assertTrue`, `assertNotNull`, `assertThrows`)
- [ ] Write **integration tests** for Spring Data JPA repositories with `@DataJpaTest`
- [ ] Write **service unit tests** using **Mockito** to mock repositories
- [ ] Understand the difference between unit tests and integration tests
- [ ] Use `@SpringBootTest` for full application context tests
- [ ] Organize test data setup with `@BeforeEach`
- [ ] Verify edge cases and error conditions

---

## 1. Why Write Tests?

```
Without Tests                    With Tests
──────────────                   ────────────────────────────────
Manual testing every change      Automated verification
Bugs discovered in production    Bugs caught immediately
Afraid to refactor               Confident to refactor
No documentation of behavior     Tests document expected behavior
Hard to know what broke          Failing test pinpoints the issue
```

---

## 2. The AAA Pattern

Every good test follows the **Arrange-Act-Assert** (AAA) structure:

```
┌─────────────────────────────────────────────────────────┐
│  ARRANGE  │  Set up test data and preconditions          │
├─────────────────────────────────────────────────────────┤
│  ACT      │  Call the method/function being tested       │
├─────────────────────────────────────────────────────────┤
│  ASSERT   │  Verify the result matches expectations      │
└─────────────────────────────────────────────────────────┘
```

### Example

```java
@Test
void testSaveProduit() {
    // ARRANGE — prepare test data
    Categorie cat = new Categorie(null, "Electronique", null);
    Produit produit = new Produit(null, "Laptop", 1200.0, 5, cat);

    // ACT — execute the method under test
    Produit saved = produitService.saveProduit(produit);

    // ASSERT — verify the outcome
    assertNotNull(saved.getId());
    assertEquals("Laptop", saved.getDesignation());
    assertEquals(1200.0, saved.getPrix());
}
```

---

## 3. JUnit 5 Annotations Reference

| Annotation | Purpose | Example |
|------------|---------|---------|
| `@Test` | Marks a method as a test | `@Test void testSave() {...}` |
| `@BeforeEach` | Runs before **every** test method | Set up test data |
| `@AfterEach` | Runs after **every** test method | Clean up resources |
| `@BeforeAll` | Runs once before all tests in the class | Static setup (DB connection) |
| `@AfterAll` | Runs once after all tests in the class | Static cleanup |
| `@DisplayName` | Friendly test name in reports | `@DisplayName("Should save product")` |
| `@Disabled` | Skip this test | `@Disabled("Not yet implemented")` |
| `@RepeatedTest(n)` | Run test n times | `@RepeatedTest(5)` |
| `@ParameterizedTest` | Run test with multiple inputs | See section 7 |

---

## 4. JUnit 5 Assertions

### 4.1 Basic Assertions

```java
import static org.junit.jupiter.api.Assertions.*;

// Check values are equal
assertEquals(expected, actual);
assertEquals(1200.0, produit.getPrix(), 0.001); // delta for doubles

// Check object is not null
assertNotNull(savedProduit.getId());
assertNotNull(savedProduit);

// Check object is null
assertNull(produit.getCategorie());

// Boolean assertions
assertTrue(list.size() > 0);
assertFalse(list.isEmpty());

// Check exact object identity (same reference)
assertSame(expectedObject, actualObject);

// Collections
assertEquals(3, list.size());
assertTrue(list.contains(expectedElement));
```

### 4.2 Exception Assertions

```java
// Verify that an exception IS thrown
@Test
void testSaveWithInvalidPrice() {
    // ARRANGE
    Produit produit = new Produit(null, "Test", -10.0, 1, null);

    // ACT + ASSERT — verify exception is thrown
    Exception ex = assertThrows(IllegalArgumentException.class,
        () -> produitService.saveProduit(produit)
    );

    // Also verify the exception message
    assertTrue(ex.getMessage().contains("prix"));
}

// Verify that NO exception is thrown
@Test
void testSaveValidProduit() {
    Produit p = new Produit(null, "Valid", 100.0, 5, null);
    assertDoesNotThrow(() -> produitService.saveProduit(p));
}
```

### 4.3 Multiple Assertions with assertAll

```java
// Execute all assertions even if one fails
@Test
void testProduitFields() {
    Produit p = produitService.getProduitById(1L).orElseThrow();

    assertAll("Produit fields",
        () -> assertEquals("Laptop", p.getDesignation()),
        () -> assertEquals(1200.0, p.getPrix()),
        () -> assertNotNull(p.getCategorie()),
        () -> assertEquals("Electronique", p.getCategorie().getNomCategorie())
    );
}
```

---

## 5. Testing Spring Data JPA Repositories

### 5.1 @DataJpaTest

`@DataJpaTest` configures a test that:
- Only loads JPA components (repositories, entities)
- Uses an in-memory H2 database (or embedded DB)
- Rolls back each test after execution

```java
package ma.projet.repositories;

import ma.projet.entities.Categorie;
import ma.projet.entities.Produit;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

@DataJpaTest   // ← Only loads JPA layer; uses embedded H2 DB
class ProduitRepositoryTest {

    @Autowired
    private ProduitRepository produitRepository;

    @Autowired
    private CategorieRepository categorieRepository;

    private Categorie electronique;
    private Produit laptop;
    private Produit telephone;

    @BeforeEach
    void setUp() {
        // ARRANGE — create and persist test data before each test
        electronique = categorieRepository.save(
            new Categorie(null, "Electronique", null)
        );

        laptop = produitRepository.save(
            new Produit(null, "Laptop HP", 1200.0, 10, electronique)
        );

        telephone = produitRepository.save(
            new Produit(null, "Samsung Galaxy", 800.0, 25, electronique)
        );
    }

    @Test
    void testFindById() {
        // ACT
        Optional<Produit> found = produitRepository.findById(laptop.getId());

        // ASSERT
        assertTrue(found.isPresent());
        assertEquals("Laptop HP", found.get().getDesignation());
    }

    @Test
    void testFindByDesignationContaining() {
        // ACT
        List<Produit> results = produitRepository.findByDesignationContaining("Laptop");

        // ASSERT
        assertEquals(1, results.size());
        assertEquals("Laptop HP", results.get(0).getDesignation());
    }

    @Test
    void testFindByPrixBetween() {
        // ACT
        List<Produit> results = produitRepository.findByPrixBetween(700.0, 1000.0);

        // ASSERT
        assertEquals(1, results.size());
        assertEquals("Samsung Galaxy", results.get(0).getDesignation());
    }

    @Test
    void testFindByCategorieNomCategorie() {
        // ACT
        List<Produit> results = produitRepository.findByCategorieNomCategorie("Electronique");

        // ASSERT
        assertEquals(2, results.size());
    }

    @Test
    void testSaveProduit() {
        // ARRANGE
        Produit newProduit = new Produit(null, "iPad Pro", 1500.0, 5, electronique);

        // ACT
        Produit saved = produitRepository.save(newProduit);

        // ASSERT
        assertNotNull(saved.getId());
        assertEquals("iPad Pro", saved.getDesignation());
        assertEquals(3, produitRepository.count()); // 2 from setUp + 1 new
    }

    @Test
    void testDeleteProduit() {
        // ACT
        produitRepository.deleteById(laptop.getId());

        // ASSERT
        assertFalse(produitRepository.existsById(laptop.getId()));
        assertEquals(1, produitRepository.count());
    }
}
```

---

## 6. Testing the Service Layer (Unit Tests with Mockito)

### 6.1 What is Mocking?

When testing the service layer, we don't want to use a real database. **Mockito** creates fake (mock) objects that simulate repository behavior.

```
Real Test (Integration)              Unit Test with Mock
────────────────────                 ────────────────────────────
Service → Real Repository → DB       Service → Mock Repository → (no DB)
Slow (DB connection needed)          Fast (no IO)
Tests full stack                     Tests service logic only
Needs test database                  No database needed
```

### 6.2 Service Unit Test Setup

```java
package ma.projet.services;

import ma.projet.entities.Categorie;
import ma.projet.entities.Produit;
import ma.projet.repositories.ProduitRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)  // ← Enables Mockito
class ProduitServiceTest {

    @Mock
    private ProduitRepository produitRepository;  // ← Fake repository

    @InjectMocks
    private ProduitServiceImpl produitService;  // ← Real service with mocked repo injected

    private Categorie electronique;
    private Produit laptop;

    @BeforeEach
    void setUp() {
        electronique = new Categorie(1L, "Electronique", null);
        laptop = new Produit(1L, "Laptop HP", 1200.0, 10, electronique);
    }

    @Test
    void testGetAllProduits() {
        // ARRANGE — tell the mock what to return
        when(produitRepository.findAll())
            .thenReturn(Arrays.asList(laptop));

        // ACT
        List<Produit> result = produitService.getAllProduits();

        // ASSERT
        assertEquals(1, result.size());
        assertEquals("Laptop HP", result.get(0).getDesignation());

        // Verify the repository method was actually called
        verify(produitRepository, times(1)).findAll();
    }

    @Test
    void testGetProduitById_Found() {
        // ARRANGE
        when(produitRepository.findById(1L))
            .thenReturn(Optional.of(laptop));

        // ACT
        Optional<Produit> result = produitService.getProduitById(1L);

        // ASSERT
        assertTrue(result.isPresent());
        assertEquals("Laptop HP", result.get().getDesignation());
    }

    @Test
    void testGetProduitById_NotFound() {
        // ARRANGE
        when(produitRepository.findById(999L))
            .thenReturn(Optional.empty());

        // ACT
        Optional<Produit> result = produitService.getProduitById(999L);

        // ASSERT
        assertFalse(result.isPresent());
    }

    @Test
    void testSaveProduit() {
        // ARRANGE
        Produit newProduit = new Produit(null, "New Laptop", 900.0, 3, electronique);
        Produit savedProduit = new Produit(5L, "New Laptop", 900.0, 3, electronique);
        
        when(produitRepository.save(newProduit)).thenReturn(savedProduit);

        // ACT
        Produit result = produitService.saveProduit(newProduit);

        // ASSERT
        assertNotNull(result.getId());
        assertEquals(5L, result.getId());
        verify(produitRepository).save(newProduit);
    }

    @Test
    void testSaveProduit_InvalidPrice_ThrowsException() {
        // ARRANGE
        Produit invalidProduit = new Produit(null, "Bad Product", -50.0, 1, null);

        // ACT + ASSERT
        assertThrows(IllegalArgumentException.class,
            () -> produitService.saveProduit(invalidProduit)
        );

        // Verify the repository was NEVER called (validation rejected it)
        verify(produitRepository, never()).save(any());
    }

    @Test
    void testGetProduitsByPrixRange() {
        // ARRANGE
        List<Produit> expected = Arrays.asList(laptop);
        when(produitRepository.findByPrixBetween(1000.0, 1500.0))
            .thenReturn(expected);

        // ACT
        List<Produit> result = produitService.getProduitsByPrixRange(1000.0, 1500.0);

        // ASSERT
        assertEquals(1, result.size());
        verify(produitRepository).findByPrixBetween(1000.0, 1500.0);
    }
}
```

---

## 7. Mockito Cheat Sheet

### 7.1 Setting Up Stubs (When...ThenReturn)

```java
// Return a value when called
when(repo.findById(1L)).thenReturn(Optional.of(product));

// Return empty Optional
when(repo.findById(999L)).thenReturn(Optional.empty());

// Return a list
when(repo.findAll()).thenReturn(Arrays.asList(p1, p2, p3));

// Throw an exception
when(repo.findById(anyLong())).thenThrow(new RuntimeException("DB error"));

// Match any argument
when(repo.save(any(Produit.class))).thenReturn(savedProduct);
```

### 7.2 Verifying Interactions

```java
// Verify method was called exactly once
verify(repo, times(1)).findAll();

// Verify method was called exactly twice
verify(repo, times(2)).save(any());

// Verify method was NEVER called
verify(repo, never()).deleteById(anyLong());

// Verify method was called at least once
verify(repo, atLeastOnce()).findAll();

// Verify no more interactions with the mock
verifyNoMoreInteractions(repo);
```

### 7.3 Argument Matchers

```java
// Match any value
any()
anyLong()
anyString()
anyDouble()

// Match specific value
eq(1L)
eq("Electronique")

// Match with condition
argThat(p -> p.getPrix() > 100)
```

---

## 8. Full Application Integration Tests

### 8.1 @SpringBootTest

```java
@SpringBootTest                  // Loads complete Spring application context
@Transactional                   // Roll back after each test
class ProduitIntegrationTest {

    @Autowired
    private IProduitService produitService;

    @Autowired
    private ICategorieService categorieService;

    @Test
    void testCompleteProductCreationFlow() {
        // ARRANGE
        Categorie cat = categorieService.saveCategorie(
            new Categorie(null, "Test Category", null)
        );

        // ACT
        Produit saved = produitService.saveProduit(
            new Produit(null, "Integration Test Product", 250.0, 10, cat)
        );

        // ASSERT
        assertNotNull(saved.getId());
        List<Produit> byCategory = produitService.getProduitsByCategorie("Test Category");
        assertEquals(1, byCategory.size());
    }
}
```

---

## 9. Testing Checklist

For each service method, write at least these tests:

```
✅ Happy path: correct input → expected output
✅ Empty result: valid input but no matching data
✅ Not found: ID that doesn't exist
✅ Validation: invalid input throws exception
✅ Boundary values: exactly at min/max limits
✅ Null input: what happens when null is passed?
```

---

## 10. Best Practices

### ✅ Do This

```java
// ✅ One assertion concept per test (focused tests)
@Test
void testFindById_returnsCorrectDesignation() {
    // focus only on designation
}

@Test  
void testFindById_returnsCorrectPrice() {
    // focus only on price
}

// ✅ Use @BeforeEach to avoid repetitive setup
@BeforeEach
void setUp() {
    testCategorie = new Categorie(null, "Test", null);
    testProduit = new Produit(null, "Test Produit", 100.0, 5, testCategorie);
}

// ✅ Give tests descriptive names
@Test
@DisplayName("Should return empty Optional when product ID does not exist")
void testFindById_nonExistentId_returnsEmpty() { ... }
```

### ❌ Avoid This

```java
// ❌ Don't test multiple unrelated things in one test
@Test
void testEverything() {
    // Tests save, find, delete, and filter all in one test
    // Hard to understand what failed!
}

// ❌ Don't depend on test execution order
@Test
void test2() {
    // This test assumes test1 already ran and saved data
    // Tests should be INDEPENDENT!
}

// ❌ Don't use production data in tests
@Test
void testWithRealDatabase() {
    // Never connect to production DB in tests!
}
```

---

## 11. Common Mistakes to Avoid

| Mistake | Consequence | Fix |
|---------|-------------|-----|
| Tests depend on each other | Flaky tests, random failures | Each test sets up its own data |
| Not using `@BeforeEach` | Copy-pasted setup code everywhere | Centralize in `@BeforeEach` |
| Forgetting `@ExtendWith(MockitoExtension.class)` | Mocks not initialized | Always add this for Mockito tests |
| Testing getters/setters | Wastes time; Lombok is already tested | Only test meaningful business logic |
| Asserting with `assertTrue(a.equals(b))` | Poor error messages on failure | Use `assertEquals(a, b)` |
| Not testing exception cases | Missing validation coverage | Always test `assertThrows` for invalid input |

---

## 12. Review Questions

1. What does the **AAA pattern** stand for? Describe each step with an example.

2. What is the difference between `@DataJpaTest` and `@SpringBootTest`? When would you use each?

3. Why do we use Mockito when testing the service layer? What problem does it solve?

4. Explain what `when(repo.findById(1L)).thenReturn(Optional.of(product))` does in a Mockito test.

5. What is the difference between `verify(repo, times(1)).save(any())` and `verifyNoMoreInteractions(repo)`?

6. You have a service method that calls `save()` only if the product's price is valid (> 0). Write a test to verify that `save()` is **never called** when an invalid price is provided.

7. What does `@BeforeEach` do? Why is it better than initializing test data inside each test method?

8. What does `assertAll()` do differently from multiple separate `assertEquals()` calls?

---

## 13. Practice Exercises

### Exercise 1 — Repository Tests
Write `@DataJpaTest` tests for `CategorieRepository`:
- Test saving and finding a category
- Test finding all categories after saving several
- Test deleting a category and verifying it's gone
- Test that saving a Categorie with null name raises a constraint violation

### Exercise 2 — Service Unit Tests
Write Mockito unit tests for all methods in `IProduitService`:
- `getAllProduits()` — returns list from mock
- `saveProduit()` — valid product
- `saveProduit()` — invalid price (should throw)
- `deleteProduit()` — verify `deleteById` called once

### Exercise 3 — Parameterized Tests
Write a parameterized test that verifies `findByPrixBetween()` with multiple price ranges:
- Range 0-500: 2 products
- Range 500-1000: 1 product
- Range 1000-2000: 1 product
- Range 2000-5000: 0 products

---

## 14. Summary

| Concept | Key Takeaway |
|---------|-------------|
| AAA Pattern | Arrange → Act → Assert — structure every test this way |
| `@Test` | Marks a method as a JUnit 5 test |
| `@BeforeEach` | Setup code that runs before each test |
| `assertEquals` | Verifies two values are equal (with helpful error messages) |
| `assertThrows` | Verifies an exception is thrown |
| `@DataJpaTest` | Tests the JPA layer only, using embedded DB |
| `@Mock` + `@InjectMocks` | Mockito: creates fake objects and injects them |
| `when().thenReturn()` | Tells mock what to return when called |
| `verify()` | Checks that a mock method was called |

---

## ➡️ Next Section

**[RESUME-06 → Building the Complete Application](./RESUME-06-Complete-Application.md)**  
Bring everything together: initialize data, wire all layers, and build a working Spring Boot application.

---

*📑 Back to [Index](./INDEX-Resumes.md)*
