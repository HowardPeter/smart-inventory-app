# [cite_start]BACKEND CONVENTIONS [cite: 1]

## [cite_start]1. File & folder naming [cite: 2]

### 1.1. [cite_start]Module file (controller, route, repository, ...) [cite: 3]
* [cite_start]Use a kebab-case that combines dot-based suffix[cite: 4].
* [cite_start]General format: `<feature-name>.<layer>.ts`[cite: 5].
* [cite_start]No capital letters and no ordinal numbers in the file name[cite: 6].
* [cite_start]The file must be properly placed in the corresponding layer folder for easy location[cite: 7].

### 1.2. [cite_start]Config/constant file [cite: 9]
* [cite_start]Use kebab-case for the entire file name[cite: 10].
* [cite_start]Format: `<entity-use-name>.<config|constants>.ts`[cite: 11].
* [cite_start]The file name should clearly reflect the purpose and scope of use[cite: 12].
* [cite_start]No capital letters and no ordinal numbers[cite: 13].

### 1.3. [cite_start]"index" file [cite: 15]
* [cite_start]Always name it "index.ts"[cite: 16].
* [cite_start]For re-export purposes only and does not contain business logic or business processing[cite: 17].

### 1.4. [cite_start]Module folder [cite: 18]
* [cite_start]The folder name uses lowercase[cite: 19].
* [cite_start]Layers and modules use plurals[cite: 20].
* [cite_start]Avoid vague, confusing names such as helpers, common-stuff[cite: 21].

### 1.5. [cite_start]Document file [cite: 23]
* [cite_start]Use the UPPER_SNAKE_CASE format[cite: 24].
* [cite_start]Applies to documentation or legal files at the project level[cite: 25].

---

## [cite_start]2. Style & formatting [cite: 27]

* [cite_start]**Indentation:** Use 2 spaces for each indentation level[cite: 28, 29].
* [cite_start]**Line length:** Avoid lines longer than 80 characters[cite: 30, 31]. [cite_start]Prioritize down the line to ensure readability and review code[cite: 32].
* [cite_start]**Wrapping line:** When an expression cannot be written collapsively on a line, the following principles apply[cite: 33, 34]:
  * [cite_start]Break the line after the comma[cite: 35].
  * [cite_start]Break the line before the operator[cite: 36].
  * [cite_start]The new line is aligned with the beginning of the same-level expression on the previous line[cite: 37].
* [cite_start]**Blank line:** Use a blank line in the following scenarios[cite: 40, 41]:
  * [cite_start]Between import blocks of different groups[cite: 42].
  * [cite_start]Between functions and classes[cite: 43].
  * [cite_start]Between logical blocks in the same function[cite: 44].
  * [cite_start]Between the local variable declaration and the first statement of the function[cite: 45].
  * [cite_start]Before the statement return[cite: 46].
* [cite_start]**Semicolon:** Always use a semicolon (;) at the end of each statement[cite: 47, 48].
* [cite_start]**Quote style:** * Use a single quote ('') for strings by default[cite: 49, 50]. 
  * [cite_start]Only use the literal template ('') when interpolation is needed[cite: 51]. 
  * [cite_start]Do not use double quotes ("") unless required (e.g., Escape or specific requests)[cite: 52].
* [cite_start]**Import formatting:** The import order is arranged in groups[cite: 56, 57]:
  1. [cite_start]Built-in modules[cite: 58].
  2. [cite_start]Third-party modules[cite: 59].
  3. [cite_start]Internal modules[cite: 60].
  * [cite_start]Each import group is separated from each other by 1 blank line[cite: 61].

---

## [cite_start]3. Namings [cite: 63]

[cite_start]Naming conventions aim to minimize the need to read deep into the implementation to guess the purpose of a variable, function, or class[cite: 64]. 

| Identifier type | Rules for naming |
| :--- | :--- |
| **Variables** | [cite_start]Use `lowerCamelCase`[cite: 67]. [cite_start]Variable names are given in the `<noun>` or `<verb + noun>` structure[cite: 67]. [cite_start]A noun that clearly expresses the data that is being stored[cite: 67]. [cite_start]Adjectives can be used to complement nouns when context is needed[cite: 67]. [cite_start]Variable names must describe the meaning correctly, avoiding confusing abbreviations[cite: 67]. [cite_start]Avoid generic names that do not have professional semantics[cite: 67]. |
| **Boolean variables** | [cite_start]Always use prefixes that express logical meanings such as: `is`, `has`, `can`, `will`, ...[cite: 67]. [cite_start]Variable names should be set to positive to avoid double-negatives when reading code[cite: 67]. [cite_start]Boolean must answer clearly to a true/false question[cite: 67]. |
| **Functions / Methods** | [cite_start]Use `lowerCamelCase`[cite: 67]. [cite_start]Function names always start with a verb[cite: 67]. [cite_start]Common function name structures: `<verb>`, `<verb + noun>`, `<verb + adjective + noun>`[cite: 67]. [cite_start]The name of the function should clearly represent the behavior or impact that the function performs[cite: 67]. |
| **Constants** | [cite_start]Use `UPPER_SNAKE_CASE`[cite: 67]. [cite_start]The constant name should clearly describe the business or configuration meaning[cite: 67]. [cite_start]Only for values that don't change over the lifetime of your app[cite: 67]. |
| **Enums** | [cite_start]Use `UpperCamelCase`[cite: 67]. [cite_start]Enum represents a finite set of values, which have explicit meaning in the domain[cite: 67]. |
| **Classes** | [cite_start]Use `UpperCamelCase`[cite: 67]. [cite_start]Class names are nouns, representing a specific concept or role[cite: 67]. [cite_start]Do not use verbs in class names[cite: 67]. |
| **Interfaces** | [cite_start]Use `UpperCamelCase`[cite: 67]. [cite_start]Prefix I[cite: 67]. [cite_start]The interface name reflects the role or data structure it describes[cite: 67]. |

---

## [cite_start]4. Comments [cite: 68]

[cite_start]Comments are used to aid in reading and maintaining code, not as a substitute for good naming or clear code structure[cite: 69]. [cite_start]Incorrect or outdated comments are considered a form of bug and should be treated as seriously as code[cite: 70].

* [cite_start]**General notes:** Comments should always be updated as the code changes[cite: 71, 72]. [cite_start]Comments that no longer accurately reflect the current behavior of the code are considered bugs[cite: 73]. [cite_start]Avoid vague or overly lengthy comments[cite: 74].
* [cite_start]**Comment language:** All comments in the project are in Vietnamese[cite: 75, 76].
* [cite_start]**Comment placing rules:** Comments should be used in the following cases[cite: 77, 79]:
  * [cite_start]Logic is complex, difficult to read, or difficult to reason quickly[cite: 80].
  * [cite_start]The code has special business constraints or depends on the domain context[cite: 81].
* [cite_start]**Comments should not be used in the following cases:** [cite: 83]
  * [cite_start]When the code has clearly described itself through variable names, function names, and logical structures[cite: 84].
  * [cite_start]Code has directly demonstrated its own functionality[cite: 85].
* [cite_start]**Implementation comment formats:** The project uses 4 types of implementation comments[cite: 87, 88]:
  1. [cite_start]**Single-line comments:** Used for short, simple explanations that do not occupy more than 1 line[cite: 89, 90]. [cite_start]Should be placed after a blank-line and preceded by the relevant line of code[cite: 91]. [cite_start]If a comment cannot be written on a single line, it should be in the block-comment format[cite: 92].
  2. [cite_start]**Block comments:** Used to describe complex files, classes, functions, algorithmic logic, and operations[cite: 94, 95]. [cite_start]Need to be placed after a blank-line to distinguish it from the rest of the code, before classes/functions, or inside a function to explain complex logic[cite: 96].
  3. [cite_start]**Trailing comments:** Short comments are placed with the line of code they describe, trailing comments are only used when it is necessary to clarify the meaning of a variable or context specific to that line[cite: 98, 99].
  4. [cite_start]**Note comments:** Comments with prefixes are stipulated to be temporary notes or notes for the reader[cite: 101, 102]:
     * [cite_start]`TODO:` Mark the work that needs to be done in the future[cite: 103].
     * [cite_start]`FIXME:` Mark errors, risks, or improper behaviors that need to be corrected[cite: 104].
     * [cite_start]`NOTE:` Provides important note to code readers[cite: 105].

---

## [cite_start]5. Statements [cite: 107]

* [cite_start]**Return Statement:** `return` is always placed on a separate line[cite: 108, 109]. [cite_start]Do not write any additional statements after returns in the same code block[cite: 110].
* [cite_start]**if-else statement:** Do not write `if` on a single line[cite: 111, 112]. [cite_start]Always use brackets (`{}`) for all `if`, `else if`, `else`, even if the block has only one line[cite: 113].
* [cite_start]**switch-case statement:** A switch-case statement always has a `default` to handle unexpected cases[cite: 115, 116]. [cite_start]Each case must end with a `break`, unless there is an obvious reason[cite: 117]. [cite_start]If a case deliberately does not have a break, it is necessary to add a comment `/* falls through */` at the usual position of the break to show intentionality[cite: 118].
* [cite_start]**Loop (for, while, do-while) statement:** A loop statement should always use brackets `{}` and the entire loop block should not be written on a single line[cite: 120, 121]. 

---

## [cite_start]6. Declarations [cite: 126]

* [cite_start]**Type rules:** With Typescript, it is recommended to use `unknown` instead of `any` when the data type is not clearly defined, and only use `any` in mandatory cases or temporary code[cite: 127, 128].
  * [cite_start]When using `any` for temporary code, it must be accompanied by a `TODO` comment to indicate that it will be refactored later[cite: 129].
  * [cite_start]For other cases where it is necessary to use `any`, it is necessary to have a comment explaining the reason for use[cite: 130].
* [cite_start]**Number per line:** It is recommended that each line declares only one variable or one constant[cite: 131, 132].
* [cite_start]**Function declarations:** Using arrow functions for standalone functions and callbacks, this style avoids the problems associated with this and keeps the style consistent[cite: 134, 135]. [cite_start]Limit the function to more than 2 levels because it will reduce the ability to read, debug and test[cite: 136].
* [cite_start]**Class declarations:** The order of declarations in the class should be kept consistent so that it is easy to read[cite: 137, 138]:
  1. [cite_start]Properties[cite: 139].
  2. [cite_start]Constructor[cite: 140].
  3. [cite_start]Public methods[cite: 141].
  4. [cite_start]Protected methods[cite: 142].
  5. [cite_start]Private methods[cite: 143].
* [cite_start]**Interface declarations:** The interface is only used to describe the shape of the data, and does not contain processing logic[cite: 145, 146]. 

---

## [cite_start]7. Error handlings & Loggings [cite: 147, 151]

### 7.1. [cite_start]Error handlings [cite: 147]
* [cite_start]Use `try-catch` to handle sync errors[cite: 148].
* [cite_start]For asynchronous code, always use `async/await` in combination with `try-catch`[cite: 149].
* [cite_start]Error messages need to have a clear meaning, describe the context in which the error occurred, and avoid generic messages[cite: 150].

### 7.2. [cite_start]Log levels [cite: 152]
[cite_start]Always use the correct log level according to the severity of the event[cite: 153]:
* [cite_start]**Debug:** Used for debug server information[cite: 154, 155]. [cite_start]Log intermediate variables, internal states, processing flows[cite: 156]. [cite_start]Enable only in a dev or staging environment[cite: 157].
* [cite_start]**Info:** Used for important events in the system flow[cite: 158, 159]. [cite_start]Mark a notable start/end process or business event[cite: 160].
* [cite_start]**Warn:** Used for abnormal behaviors but the system still works[cite: 161, 162]. [cite_start]Applies when the data is invalid but has a fallback mechanism[cite: 163].
* [cite_start]**Error:** Used for errors that cause a request or job to fail[cite: 164, 165]. [cite_start]Exceptions need to be handled, logged, and alerted[cite: 166].
* [cite_start]The message log must clearly describe what happened and in what context, avoiding vague logs such as error occurred, something went wrong[cite: 167].

---

## [cite_start]8. API contract [cite: 168]

* [cite_start]**Success response structure:** All API responses (successes) must follow a uniform format[cite: 169, 170]:
  * [cite_start]`success`: boolean — required[cite: 171].
  * [cite_start]`data`: main data (object | array | null)[cite: 172].
  * [cite_start]`meta`: add-on information (pagination, total, page, limit, ...) — optional[cite: 173].
  * [cite_start]`message`: Additional debug description — optional[cite: 174].
* [cite_start]**Error response structure:** All API responses (errors) must follow the format[cite: 175, 176]:
  * [cite_start]`success`: boolean — required, always `false`[cite: 177].
  * [cite_start]`status`: HTTP status code (400, 401, 403, 404, 409, 500, ...) — required[cite: 178].
  * [cite_start]`message`: a clear, easy-to-understand error description message — required[cite: 179].
* [cite_start]**HTTP status code usage:** Always use the correct HTTP status code in all cases[cite: 180, 181].
* [cite_start]**Pagination:** * Query format: `?page=x&limit=y` (x, y are natural numbers)[cite: 182, 183].
  * [cite_start]Response format: The pagination information is placed in the `meta` field[cite: 184, 185].
* [cite_start]**Sort & filter:** Parameters for sort/filter endpoints use `lowerCamelCase`, which is not abbreviated and explicit[cite: 189, 190].
* [cite_start]**Query string naming:** The parameters for endpoint queries use `lowerCamelCase`, which is abbreviated and explicit[cite: 194, 195].
* [cite_start]**Request body field naming:** The fields in the body request use `lowerCamelCase`[cite: 199, 200].

---

## [cite_start]9. Security & secret storages [cite: 202]

### 9.1. [cite_start]Environment variables [cite: 203]
* [cite_start]Absolutely do not hardcode the environment variable in the source code[cite: 204].
* [cite_start]All configurations by environment must be derived from environment variables[cite: 205].
* [cite_start]Do not commit the `.env` file or similar files, use `.env.example` instead to describe the list of necessary variables[cite: 206].

### 9.2. [cite_start]Secret & sensitive datas [cite: 207]
[cite_start]Secret/sensitive data includes (but is not limited to): API keys, jwt secrets, database credentials, passwords (including hashed passwords), emails, phones,...[cite: 208].

[cite_start]Secrets **MUST NOT** appear anywhere in[cite: 209]:
* [cite_start]Source code[cite: 210].
* [cite_start]Git history[cite: 211].
* [cite_start]Log[cite: 212].
* [cite_start]Error message[cite: 213].
* [cite_start]API response returns to the client[cite: 214].