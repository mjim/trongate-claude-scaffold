I'd like some assistance with a PHP application that I'm working on.  This application uses Trongate v2.  

Trongate v2 is a native PHP framework (no Composer, minimal third-party dependencies, snake_case naming conventions) built on a modular MVC architecture where everything — including core functionality like database access and validation — exists as a module.  The information below outlines the framework's core philosophy and key operational principles that will inform all subsequent guidance.

================================================================================
TRONGATE v2 - FRAMEWORK MEMORY FILE FOR OPENCLAW AI AGENT
================================================================================
This file documents Trongate v2's internals with extreme brevity for AI accuracy.
Each section is designed for quick lookup with zero ambiguity.

================================================================================
CORE PHILOSOPHY
================================================================================
- "Everything is a module" - All functionality (db, validation, file) is modular
- Zero third-party dependencies - No Composer, no external packages
- Native PHP only - Raw PHP, no template engines, no ORMs
- Explicit over implicit - No magic, no reflection, no auto-guessing
- AI-first design - Entire framework <2,000 lines, fits one AI context window
- No magic methods - No __call magic for uncertain behavior
- Small codebase = auditable, traceable code flow

================================================================================
ARCHITECTURE & STRUCTURE
================================================================================
DIRECTORY LAYOUT:
  /engine/          Core framework engine (5 PHP files + helpers)
  /modules/         Everything: db, validation, file, templates, etc.
  /config/          Configuration files
  /public/          Web root with index.php
  /uploads/         File uploads directory

FILE STRUCTURE:
  modules/{module}/{Module}.php              Controller (required)
  modules/{module}/{Module}_model.php        Model (optional)
  modules/{module}/views/{view_name}.php     View files (pure PHP)
  modules/{module}/css/, /js/, /images/      Module assets
  modules/{parent}/{child}/{Child}.php       Child module (nested)

CORE ENGINE FILES:
  - Trongate.php    Base controller class (properties, view rendering, module loading)
  - Core.php        Request dispatcher/router (557 lines)
  - Model.php       Model base class + data access layer (311 lines)
  - Modules.php     Static controller invocation for views (98 lines)
  - ignition.php    Bootstrap & initialization (143 lines)

================================================================================
REQUEST FLOW (URL TO RESPONSE)
================================================================================
1. /public/index.php
2. /engine/ignition.php (bootstrap, load config, load helpers, run interceptors)
3. /engine/Core.php -> serve_controller()
4. Load module controller ({Module}.php)
5. Invoke method from URL
6. Controller instantiates $this->view() or calls $this->model->method()
7. View file rendered (pure PHP)

================================================================================
CONSTANTS (Defined in config/config.php and ignition.php)
================================================================================
BASE_URL                   URL of application (e.g., 'http://localhost/my_app/')
ENV                        'dev' or 'prod' (dev = detailed errors, verbose output)
DEFAULT_MODULE             Default module if none in URL (e.g., 'welcome')
DEFAULT_METHOD             Default method if none in URL (e.g., 'index')
ERROR_404                  Module/method for 404 handler (e.g., 'welcome/error_404')
MODULE_ASSETS_TRIGGER      String to detect module assets (default: '_module')
CUSTOM_ROUTES              Array of custom routing patterns
INTERCEPTORS               Array of early-hook handlers

FRAMEWORK-DEFINED CONSTANTS (ignition.php):
REQUEST_TYPE               $_SERVER['REQUEST_METHOD'] ('GET', 'POST', 'PUT', etc.)
APPPATH                    Absolute path to app directory
SEGMENTS                   Array of URL segments [0]=module, [1]=method, [2+]=params
ASSUMED_URL                Full URL after custom routing applied

DATABASE:
$GLOBALS['databases']      Associative array of database groups from config/database.php

================================================================================
TRONGATE BASE CLASS (engine/Trongate.php)
================================================================================
PROPERTIES:
  protected ?string $module_name       Name of this module (set in constructor)
  protected string $parent_module      Parent module name (for child modules)
  protected string $child_module       Child module name (for child modules)
  private array $instances             Cache for lazy-loaded instances
  private array $loaded_modules        Cache for explicitly loaded modules

CONSTRUCTOR:
  public function __construct(?string $module_name = null): void
  - If $module_name is null, auto-detects from class name (e.g., Products -> 'products')
  - Framework passes module_name automatically from URL
  - REQUIRED: Call parent::__construct($module_name) first in child constructors

METHODS:

  protected function view(string $view, array $data = [], ?bool $return_as_str = null): ?string|null
  - Renders view file from modules/{module}/views/{view}.php
  - $data: associative array of variables (extracted into view scope)
  - $return_as_str: true = return as string, false = echo output
  - Data key 'view_module' overrides module name lookup
  - Throws Exception if view not found
  - Priority: 1) child module path, 2) standard module path, 3) derived from URL segment

  protected function module(string $target_module): void
  - Lazy-loads a module controller and caches it in $loaded_modules
  - Handles hyphenated child modules (e.g., 'cars-accessories')
  - For child modules, also caches under child name for short access
  - After calling: $this->target_module->method() or $this->child->method() works
  - MODELS MUST call this explicitly; CONTROLLERS auto-load via __get

  protected function read_manifest(string $path): array|bool
  - Reads {path}/manifest.php and returns as array, or false if not found
  - Used for module metadata/configuration

MAGIC METHOD:
  public function __get(string $key): object
  - Automatic lazy-loader for validation, model, and other modules
  - Returns cached instance on second access
  - For 'validation': injects caller reference (this controller)
  - For 'model': creates Model instance for this module
  - For others: calls module() to lazy-load

================================================================================
MODEL BASE CLASS (engine/Model.php)
================================================================================
PURPOSE:
  - Automatic loading of {Module}_model.php class
  - Method delegation to module-specific model methods
  - Database connection management (default + alternative db groups)
  - Module loading capability (models can use other modules)

PROPERTIES:
  private array $loaded_models        Cache for module-specific model instances
  private array $db_instances         Cache for Db connections (default + alternatives)
  private array $loaded_modules       Cache for loaded modules
  private ?string $current_module     Module that instantiated this Model

CONSTRUCTOR:
  public function __construct(?string $module_name = null): void
  - $module_name is the module this model serves
  - Framework passes this automatically

MAGIC METHOD __get(string $key):
  - If $key === 'db' → returns Db('default')
  - If $key is configured in $GLOBALS['databases'] → returns Db($key)
  - If $key is loaded module → returns that module instance
  - Else → throws helpful Exception

METHODS:

  public function module(string $target_module): void
  - Explicitly load another module from model code
  - After calling: $this->target_module->method() works
  - Required in models (unlike controllers which auto-load)

  public function __call(string $method, array $arguments): mixed
  - Intercepts unknown method calls (e.g., $this->my_custom_method())
  - Auto-loads {Module}_model.php if not already loaded
  - Delegates call to module-specific model class
  - Throws Exception if method not found in model

================================================================================
CORE DISPATCHER (engine/Core.php) - REQUEST ROUTING
================================================================================
ROUTING TYPES:
  1. Vendor assets: /vendor/lib/file.css → serve from /vendor/ (static)
  2. Module assets: /products_module/css/style.css → serve from module assets
  3. Controller requests: /products/show/15 → load Products.php, call show()

SECURITY:
  - Methods starting with '_' are BLOCKED from URL access (403 Forbidden)
  - Sanitizes module/method names: preg_replace('/[^a-z0-9-_]/', '')
  - Query params are stripped before routing
  - block_url() function can prevent entire modules or specific methods

REQUEST PARSING:
  SEGMENTS array: 0=module, 1=method, 2+=params (1-indexed in helper functions!)
  ASSUMED_URL: full URL after custom routing applied
  REQUEST_TYPE: HTTP method (GET, POST, PUT, DELETE, etc.)

CUSTOM ROUTING:
  - Defined in /config/custom_routing.php
  - Syntax: CUSTOM_ROUTES = ['pattern' => 'destination']
  - Patterns: use (:num) for digits, (:any) for any character
  - Matching: done before controller dispatch
  - Example: '/blog/(:num)' => 'posts/show/$1'

INTERCEPTORS (Early Hooks):
  - Defined in config.php as INTERCEPTORS array
  - Run BEFORE controller dispatch
  - Syntax: INTERCEPTORS = ['module' => 'method']
  - Use cases: auth checks, maintenance mode, logging
  - Run immediately in ignition.php

================================================================================
MODULES CLASS (engine/Modules.php) - STATIC INVOCATION
================================================================================
PURPOSE: Call modules from views or other code (not URL)

PUBLIC STATIC METHOD:
  public static function run(string $module_method, mixed $data = null): mixed
  - Format: "Module/Method" (case-insensitive module, lowercase method)
  - $data: any PHP type (array, string, int, bool, NULL, object)
  - No data type restrictions - pass whatever your module needs
  - Returns whatever the method returns
  - Used in views: <?= Modules::run('pagination/display', $data) ?>

EXAMPLES:
  - Modules::run('users/stats', $user_data)
  - Modules::run('reports/generate_pdf', $id)
  - Modules::run('cars-accessories/list', ['parent' => 'toyota'])

================================================================================
MODULE LOADING IN CONTROLLERS vs MODELS
================================================================================
CONTROLLERS (auto-load via __get):
  $vat = $this->tax->calculate($amount);          // Auto-loads first time
  $this->module('email');                         // Optional explicit load
  $result = $this->email->send($to, $subject);

MODELS (must load explicitly):
  $this->module('email_sender');                  // REQUIRED
  $result = $this->email_sender->send($to, $subject);

VIEWS (use static Modules::run):
  <?= Modules::run('users/profile', $user_data) ?>

CHILD MODULES:
  - Format: 'parent-child' (hyphen, not slash)
  - Path: modules/parent/child/Child.php
  - Load: $this->module('parent-child') or $this->module('child')
  - After load, access as $this->child->method() or $this->parent_child->method()

================================================================================
URL SEGMENT ACCESS (url_helper.php)
================================================================================
SEGMENT NUMBERING: 1-indexed (segment 1 is module, segment 2 is method)

int|string segment(int $num, string $var_type = ''): mixed
  - Get URL segment at position $num
  - Returns 0 if not exists (not false!)
  - Optional type casting: 'int', 'float', 'bool', 'string'
  - Examples:
    segment(1)        // Module name
    segment(2)        // Method name
    segment(3, 'int') // Third param as integer, 0 if not exists
    segment(4, 'str') // Fourth param as string

string segment_str(int $num): string
  - Same as segment($num, 'string')
  - Explicit string type

int segment_int(int $num): int
  - Same as segment($num, 'int')
  - Explicit int type

int get_num_segments(): int
  - Total number of segments in URL

string get_last_segment(): string
  - Last segment of URL

================================================================================
POST DATA RETRIEVAL (form_helper.php)
================================================================================
mixed post(string $field_name = '', bool $clean_up = false, string $cast_numeric = ''): mixed
  - Get POST value by field name
  - $clean_up: true = trim whitespace, sanitize, convert empty to ''
  - $cast_numeric: empty string = no casting, or use 'int', 'float'
  - No field_name = return entire $_POST array
  - Returns NULL if field doesn't exist AND $clean_up = false
  - Returns '' if field doesn't exist AND $clean_up = true

EXAMPLES:
  post('username', true)                   // Get field, trimmed
  post('user_id', true, 'int')            // Get field as integer
  post()                                  // Entire $_POST array
  $data = post('submit', true);

================================================================================
URL HELPERS (url_helper.php)
================================================================================
string current_url(): string
  - Full current URL with query string
  - No trailing slash

string previous_url(): string
  - URL of previous page (from session)
  - Empty string if not available

string remove_query_string(string $string): string
  - Strips query string from URL

void redirect(string $target_url): void
  - HTTP redirect to $target_url
  - Calls exit() - halts execution

string anchor(string $url, string $text, array $attributes = []): string
  - Generate <a> tag with XSS protection on text
  - $attributes: associative array (class, id, onclick, etc.)
  - XSSES text via out()
  - Example: anchor(BASE_URL.'tasks/show/15', 'View Task', ['class' => 'button'])

================================================================================
FORM HELPERS (form_helper.php)
================================================================================
FORM STRUCTURE:
  form_open($location, $attributes)           // <form> tag, includes CSRF token
  form_open_upload($location, $attributes)    // <form enctype="multipart/form-data">
  form_close()                                // </form> (handles CSRF token output)

INPUT GENERATORS:
  form_input($name, $value, $attributes)
  form_email($name, $value, $attributes)
  form_password($name, $value, $attributes)
  form_search($name, $value, $attributes)
  form_number($name, $value, $attributes)
  form_hidden($name, $value, $attributes)
  form_textarea($name, $value, $attributes)
  form_label($label_text, $attributes)
  
  form_checkbox($name, $value, $checked, $attributes)
  form_radio($name, $value, $checked, $attributes)
  
  form_date($name, $value, $attributes)
  form_datetime_local($name, $value, $attributes)
  form_time($name, $value, $attributes)
  form_month($name, $value, $attributes)
  form_week($name, $value, $attributes)

DROPDOWNS:
  form_dropdown($name, $options, $selected_key, $attributes)
  - $options: ['key1' => 'Label 1', 'key2' => 'Label 2']
  - $selected_key: which key is pre-selected

BUTTONS:
  form_submit($name, $value, $attributes)      // <button type="submit">
  form_button($name, $value, $attributes)      // <button type="button">

FILE INPUT:
  form_file_select($name, $attributes)         // <input type="file">

UTILITIES:
  validation_errors($first_arg = '', $closing_html = ''): string
  - Returns formatted error list or empty string
  - $first_arg: opening HTML (e.g., '<div class="alert">')
  - Automatically fetches errors from validation module

================================================================================
STRING HELPERS (string_helper.php)
================================================================================
string truncate_str(string $str, int $max_length): string
  - Truncate string, add '...'

string truncate_words(string $str, int $max_words): string
  - Truncate to word count, add '...'

string get_last_part(string $str, string $delimiter): string
  - Get portion after last delimiter
  - Example: get_last_part('john@example.com', '@') => 'example.com'

string extract_content(string $string, string $start, string $end): string
  - Extract substring between two delimiters
  - Returns empty if delimiters not found

string remove_substr_between(string $start, string $end, string $haystack, bool $remove_all = false): string
  - Remove content between two substrings

string nice_price(mixed $num, string $currency_symbol = ''): string
  - Format number as price (commas, 2 decimals)
  - Example: nice_price(1234.5, '$') => '$1,234.50'

string url_title(string $str, bool $transliteration = true): string
  - Convert to URL-friendly slug (lowercase, hyphens)
  - Example: url_title('Hello World') => 'hello-world'

string sanitize_filename(string $filename, bool $transliteration = true, int $max_length = 255): string
  - Safe filename for storage
  - Removes/replaces unsafe characters

string out(string $input, string $output_format = 'html', string $encoding = 'UTF-8'): string
  - XSS-safe output - ALWAYS use in views
  - $output_format: 'html', 'url', 'csv', 'json'
  - Example: <?= out($user_input) ?>

string make_rand_str(int $length, bool $uppercase = false): string
  - Generate random string
  - Example: make_rand_str(16, true) => 'ABCD1234EFGH5678'

string replace_html_tags(string $content, array $specifications): string
  - Convert HTML tags based on specs

string remove_html_code(string $content, string $opening_pattern, string $closing_pattern): string
  - Remove sections of HTML

string filter_str(string $str, string $allowed_tags = ''): string
  - Remove/filter HTML tags (except allowed)

string filter_name(string $name, string $allowed_chars = 'a-zA-Z0-9-_ '): string
  - Remove disallowed characters

================================================================================
UTILITIES HELPERS (utilities_helper.php)
================================================================================
void block_url(string $block_path): void
  - Prevent direct browser access to module or method
  - Returns 403 Forbidden if accessed via URL
  - Code access still works
  - Usage: block_url('payment') or block_url('reports/generate_pdf')

void json(mixed $data, bool $kill_script = true): void
  - Output $data as JSON (prettified)
  - $kill_script: true = exit after output
  - Sets Content-Type: application/json

string ip_address(): string
  - Client IP address (checks X-Forwarded-For, etc.)

void display(string $view, array $data = []): void
  - Render view within current module

array return_file_info(string $file_path): array
  - Returns ['filename' => name, 'extension' => ext]
  - Example: return_file_info('document.pdf') => ['filename' => 'document', 'extension' => 'pdf']

array sort_by_property(array $array, string $property, string $direction = 'asc'): array
  - Sort array of assoc arrays by key
  - $direction: 'asc' or 'desc'

array sort_rows_by_property(array $array, string $property, string $direction = 'asc'): array
  - Sort array of objects by property

bool from_trongate_mx(): bool
  - Check if request came from Trongate MX (framework's JS tool)

================================================================================
FLASHDATA HELPERS (flashdata_helper.php)
================================================================================
void set_flashdata(string $msg): void
  - Store one-time message in session
  - Automatically cleared after display

string flashdata(string $opening_html = '', string $closing_html = ''): string
  - Retrieve and display flashdata, clear it
  - Returns empty string if no message
  - Example: <?= flashdata('<div class="alert">', '</div>') ?>

TYPICAL USAGE:
  Controller: set_flashdata('Record saved successfully');
  Controller: redirect('records/manage');
  View: <?= flashdata() ?>   // Displays and clears

================================================================================
DATABASE MODULE (modules/db/Db.php)
================================================================================
CONSTRUCTOR:
  public function __construct(?string $module_name = null, ?string $db_group = null)
  - $module_name: passed by framework (use in controllers, models)
  - $db_group: database group name ('default' if null)
  - Uses config from $GLOBALS['databases'][$db_group]
  - Throws Exception if group not configured
  - Supports multiple database groups (analytics, reporting, etc.)

CORE METHODS:

  int insert(array $data, string $table): int
  - Insert single record
  - Returns ID of newly inserted record
  - Example: $db->insert(['name' => 'John', 'email' => 'john@example.com'], 'users')

  bool update(int $id, array $data, string $table): bool
  - Update record by ID (id = primary key)
  - Example: $db->update(15, ['name' => 'Jane'], 'users')

  bool delete(int $id, string $table): bool
  - Delete record by ID

  array insert_batch(array $records, string $table): array
  - Insert multiple records at once
  - $records: array of assoc arrays

  int count(string $table): int
  - Count total records in table

  array get(string $table, string $order_by = '', string $order_direction = 'asc', string $return_type = 'object'): array
  - Fetch all records (optionally ordered)
  - $return_type: 'object' or 'array'
  - Returns array of records

  object|array|false get_where(int $id, string $table, string $return_type = 'object'): object|array|false
  - Get single record by ID
  - False if not found

  object|array|false get_one_where(string $column, mixed $value, string $table, string $return_type = 'object'): object|array|false
  - Get single record by column value
  - Example: $user = $db->get_one_where('email', 'john@example.com', 'users')

  array get_where_in(string $table, string $column, array $values, array $options = []): array
  - Get records where column IN (values)
  - Example: $db->get_where_in('products', 'category_id', [1, 2, 3])

  array query(string $sql, string $return_type = 'object'): array
  - Execute raw SQL query
  - Parameter binding via ? placeholders: query("SELECT * FROM users WHERE id = ?", ['123'])
  - Note: query() is NOT parameter-binding; use query_bind() instead

  array query_bind(string $sql, array $params, string $return_type = 'object'): array
  - Execute raw SQL with parameter binding
  - Named placeholders: ":column"
  - Example: query_bind("SELECT * FROM users WHERE id = :id", ['id' => $user_id])

  bool table_exists(string $table): bool
  - Check if table exists

  array get_tables(): array
  - Get all table names in database

  array describe_table(string $table, bool $names_only = false): array
  - Get table structure/columns
  - $names_only: true = just column names

  bool attempt_truncate(string $table, bool $validate_table = true): bool
  - Truncate table (only if empty of foreign keys)

  void resequence_ids(string $table): void
  - Auto-increment IDs in sequence

ALTERNATIVE DB GROUPS (models):
  $this->analytics->get('reports')   // Uses analytics db group
  $this->db->get('products')         // Uses default db group

================================================================================
VALIDATION MODULE (modules/validation/Validation.php)
================================================================================
METHODS:

  void set_rules(string $field_name, string $field_label, string $rules): void
  - Configure validation rules for a field
  - Rules: pipe-separated (e.g., 'required|min_length[2]|max_length[50]')
  - Called before run()
  - Multiple calls for multiple fields

  bool run(): bool
  - Execute all configured validations
  - Returns true if all pass, false if any fail
  - Errors stored in $this->form_submission_errors
  - Errors also stored in $_SESSION['form_submission_errors']

  void set_language(string $lang): void
  - Set validation language ('en', 'fr', 'es')
  - For error message translations

  void reset_language(): void
  - Reset to system default language

  array get_errors(): array
  - Get all validation errors as assoc array
  - Keys = field names, values = error messages

VALIDATION RULES (Built-in):
  required                          Must be non-empty
  min_length[n]                     Minimum string length
  max_length[n]                     Maximum string length
  exact_length[n]                   Exact string length
  matches[field]                    Match another field value
  regex_match[pattern]              Match regex pattern
  valid_email                       Valid email format
  valid_url                         Valid URL format
  valid_ip                          Valid IP address
  numeric                           Must be numeric
  integer                           Must be integer
  decimal                           Must be decimal number
  alpha                             Only letters A-Z
  alphanum                          Only alphanumeric
  alpha_numeric_spaces              Alphanumeric + spaces
  alpha_dash                        Alphanumeric + dashes + underscores
  alpha_underscore                  Alphanumeric + underscores
  valid_base64                      Valid base64 string
  is_unique[table.column]           Unique in database (e.g., is_unique[users.email])
  callback_method_name              Custom callback validation (must call set_caller)

CUSTOM CALLBACKS:
  public function username_check(string $value): string|bool {
      block_url('members/username_check');
      if ($this->model->username_exists($value)) {
          return 'Username already taken';  // Error message
      }
      return true;  // Validation passed
  }
  // Then set rule: 'callback_username_check'

TYPICAL USAGE:
  $this->validation->set_rules('email', 'email address', 'required|valid_email');
  $this->validation->set_rules('age', 'age', 'required|integer|min_length[1]|max_length[3]');
  
  if ($this->validation->run() === true) {
      // Data is valid
  } else {
      // Redisplay form with errors
      validation_errors();
  }

================================================================================
FLASHDATA (modules/flashdata/Flashdata.php)
================================================================================
- One-time messages stored in $_SESSION
- Automatically cleared after first display
- No special database required

USAGE:
  // In controller after action:
  set_flashdata('Task created successfully');
  redirect('tasks/manage');

  // In view:
  <?= flashdata() ?>
  // Displays: <p>Task created successfully</p> (then clears)

================================================================================
TEMPLATES MODULE (modules/templates/Templates.php)
================================================================================
METHODS:

  void admin(array $data): void
  - Render content within admin template wrapper
  - Requires $data['view_module'] and $data['view_file']
  - Layout: templates/views/admin.php with sidebar/header

  void public(array $data): void
  - Render content within public template wrapper
  - For public-facing pages
  - Layout: templates/views/public.php

TYPICAL USAGE:
  $data = [
      'headline' => 'User Management',
      'rows' => $this->model->get_all_users(),
      'view_module' => 'users',
      'view_file' => 'manage'
  ];
  $this->templates->admin($data);

================================================================================
TRONGATE SECURITY (modules/trongate_security/)
================================================================================
METHODS:

  void make_sure_allowed(): void
  - Verify user is authenticated (via trongate_administrators)
  - Redirects to login if not authenticated
  - Call at start of admin methods

  void csrf_protect(): void
  - Verify CSRF token for POST requests
  - Blocks request if token missing or invalid

AUTOMATIC FEATURES:
  - CSRF tokens generated automatically in form_open()
  - CSRF tokens validated in validation->run()
  - XSS protection via out() helper

================================================================================
FILE UPLOAD (modules/file/File.php)
================================================================================
- Handles file uploads, validation, moving to uploads directory
- Part of framework, not detailed here (use in uploads module)

================================================================================
IMAGE HANDLING (modules/image/Image.php)
================================================================================
- Image resize, crop, watermark operations
- Requires GD library
- Used in image-heavy applications

================================================================================
PAGINATION (modules/pagination/Pagination.php)
================================================================================
USAGE IN CONTROLLER:
  $data['pagination_data'] = [
      'total_rows' => $this->model->count_all(),
      'page_num_segment' => 3,
      'limit' => 20,
      'pagination_root' => 'products/manage',
      'record_name_plural' => 'products'
  ];

USAGE IN VIEW:
  <?= Modules::run('pagination/display', $pagination_data) ?>

================================================================================
CODING PATTERNS & CONVENTIONS
================================================================================
NAMING:
  - snake_case for everything (functions, variables, methods)
  - UPPERCASE for constants
  - Lowercase modules (url will be lowercase)
  - PascalCase for class names only

BRACING (K&R Style):
  function hello_world() {
      echo "Hello";
  }
  
  if ($condition) {
      do_something();
  } else {
      do_other();
  }

RETURN TYPES:
  - All functions should have explicit return types
  - Use union types: string|int|false
  - Use void for functions with no return

METHOD VISIBILITY:
  - public: accessible from anywhere
  - protected: only in class/subclass
  - private: only in class (rare in controllers)
  - _ prefix: signals "internal", should be blocked with block_url()

DOCBLOCKS:
  - Use PHPDoc style (/** */)
  - Include @param, @return, @throws
  - Describe behavior clearly

================================================================================
COMMON PATTERNS & ANTI-PATTERNS
================================================================================
CORRECT: Auto-load modules in controllers
  $result = $this->email->send($to, $subject);  // Works

INCORRECT: Auto-load modules in models (fails silently)
  // In model - WRONG:
  $result = $this->email->send($to, $subject);  // Does NOT auto-load
  
CORRECT: Explicit load in models
  // In model - RIGHT:
  $this->module('email');
  $result = $this->email->send($to, $subject);

CORRECT: Access database from models
  $users = $this->db->get('users');
  $stats = $this->analytics->get('reports');  // Alternative db group

CORRECT: Call modules from views
  <?= Modules::run('pagination/display', $data) ?>

INCORRECT: Try to access URL segments in models
  // WRONG: Models don't have URL context
  $id = segment(3, 'int');
  
CORRECT: Pass data to models
  // In controller:
  $id = segment(3, 'int');
  $data = $this->model->find_by_id($id);
  
  // In model:
  public function find_by_id(int $id): object|false {
      return $this->db->get_one_where('id', $id, 'users');
  }

CHECKBOX CONVERSION (Database ↔ Form):
  // Database: 0 or 1 (integer)
  // Form: POST = missing or '1' (string)
  
  // In model get_data_for_edit():
  $data['complete'] = (bool) $record->complete;  // 0/1 → bool
  
  // In model get_post_data_for_database():
  $data['complete'] = (int) (bool) post('complete', true);  // POST → 0/1

REQUEST_TYPE CONSTANT:
  if (REQUEST_TYPE === 'GET') { ... }
  if (REQUEST_TYPE === 'POST') { ... }

================================================================================
SECURITY PRACTICES
================================================================================
- Always use out() for user input output:
  <?= out($user_input) ?>

- Always use parameter binding for SQL:
  $db->query_bind("SELECT * FROM users WHERE id = :id", ['id' => $id])

- Use form_open() / form_close() for CSRF protection:
  form_open('module/method');  // Includes CSRF token
  form_close();                 // Includes hidden CSRF token output

- Use validation with callbacks for custom checks:
  set_rules('email', 'email', 'callback_email_unique');

- Block sensitive methods from URL:
  block_url('payments/process');  // Can only be called from code

- Authenticate admin users:
  $this->trongate_security->make_sure_allowed();

================================================================================
DEVELOPMENT WORKFLOW
================================================================================
1. Create module folder: /modules/{module}/
2. Create controller: /modules/{module}/{Module}.php (extends Trongate)
3. Create views: /modules/{module}/views/{view}.php (pure PHP)
4. Create model (optional): /modules/{module}/{Module}_model.php (extends Model)
5. Access via URL: /{module}/{method} or /{module}/{method}/{param1}/...
6. Call views: $this->view('view_name', $data)
7. Call models: $this->model->method_name()
8. Load other modules: $this->module('other')

MODULES ARE PORTABLE:
- Copy entire module folder to another Trongate app
- Zero configuration needed
- Instant reusability

================================================================================
CONFIGURATION FILES
================================================================================
/config/config.php
  - BASE_URL, ENV, DEFAULT_MODULE, DEFAULT_METHOD, ERROR_404
  - INTERCEPTORS array for early hooks

/config/database.php
  - $databases array with db groups
  - Each group: host, port, user, password, database

/config/custom_routing.php
  - CUSTOM_ROUTES array with patterns and destinations
  - Supports (:num) and (:any) placeholders

/config/site_owner.php
  - Optional metadata about site/owner

================================================================================
PERFORMANCE FEATURES
================================================================================
- Lazy-load modules (only loaded when first accessed)
- Lazy-load database connections
- Cached module instances (don't reload)
- Minimal file includes
- No Composer autoloading overhead
- No query builder (raw SQL is faster)
- Zero ORM overhead
- Sessions use default PHP handler (native, fast)

================================================================================
COMMON GOTCHAS
================================================================================
1. Models MUST call $this->module('name') before using
   Controllers DON'T need to (auto-load via __get)

2. URL segments are 1-indexed (segment(1) = module, segment(2) = method)
   NOT 0-indexed like arrays

3. segment() returns 0 if segment doesn't exist (not false)
   Check: if (segment(3, 'int') === 0) vs if (segment(3, 'int'))

4. Child modules use hyphen in URL: /cars/accessories/show/15
   But hyphen in loading: $this->module('cars-accessories')
   Access as: $this->accessories->method() (short form)

5. POST data with cleanup returns '' not NULL for missing fields
   post('field', true) = '' when missing
   post('field') = NULL when missing

6. Checkbox POST data is missing (not '0') when unchecked
   Convert: (int) (bool) post('complete', true)

7. $this->view() doesn't return HTML by default
   Pass $return_as_str = true to get string instead of echo
   $html = $this->view('partial', $data, true);

8. Models don't have URL context
   Don't try to call segment() in models

9. form_open() and form_close() go together
   form_open() = <form> opening tag
   form_close() = hidden CSRF token + </form>

10. block_url() only blocks URL access, not code access
    block_url('payment/process');  // 403 from URL
    $this->payment->process();     // Still works from controller

================================================================================
VERSION & FRAMEWORK INFO
================================================================================
Trongate v2
- <2,000 lines total (including all core)
- No dependencies
- 23 modules
- Pure PHP, MySQL/MariaDB
- PHP 8.0+ required
- AI-optimized design
- Fits in one AI context window