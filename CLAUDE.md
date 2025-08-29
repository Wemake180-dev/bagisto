# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is Bagisto, an open-source Laravel eCommerce framework built on Laravel 11 and PHP 8.2+. It follows a modular package-based architecture with the core framework split into discrete packages under `packages/Webkul/`.

## Development Commands

### Build & Asset Compilation
- `npm run dev` - Start Vite development server for hot-reloading
- `npm run build` - Build production assets using Vite

### Laravel/PHP Commands
- `php artisan serve` - Start Laravel development server
- `php artisan migrate` - Run database migrations
- `php artisan db:seed` - Seed database with sample data
- `php artisan config:cache` - Cache configuration
- `php artisan route:cache` - Cache routes
- `php artisan view:cache` - Cache Blade views
- `php artisan queue:work` - Process background jobs

### Code Quality
- `vendor/bin/pint` - Format PHP code using Laravel Pint (PSR-12 standard with custom rules)
- `vendor/bin/phpunit` or `php artisan test` - Run PHPUnit tests
- `vendor/bin/pest` - Run Pest PHP tests (if using Pest)

### Testing
- `php artisan test --testsuite="Admin Feature Test"` - Run admin feature tests
- `php artisan test --testsuite="Core Unit Test"` - Run core unit tests  
- `php artisan test --testsuite="DataGrid Unit Test"` - Run DataGrid unit tests
- `php artisan test --testsuite="Shop Feature Test"` - Run shop feature tests

## Architecture Overview

### Modular Package Structure
Bagisto uses a modular architecture with packages located in `packages/Webkul/`:

**Core Packages:**
- `Core` - Base functionality, system config, channels, locales, currencies
- `User` - Admin user management and authentication
- `Customer` - Frontend customer functionality and management
- `Attribute` - Product attributes, families, and groups
- `Category` - Product category management
- `Product` - Product management with multiple product types support
- `Inventory` - Inventory management and stock tracking
- `Sales` - Order, invoice, shipment, and refund management
- `Payment` - Payment method integrations
- `Shipping` - Shipping method configurations
- `Tax` - Tax calculation and management

**Frontend/UI Packages:**
- `Admin` - Admin panel interface (Vue.js components)
- `Shop` - Frontend shop interface
- `Theme` - Theme system and customizations
- `Installer` - Installation wizard

**Feature Packages:**
- `CartRule` - Shopping cart rules and discounts
- `CatalogRule` - Catalog price rules
- `Checkout` - Cart and checkout functionality  
- `Marketing` - SEO, campaigns, email marketing
- `CMS` - Content management system
- `DataGrid` - Reusable data grid component
- `DataTransfer` - Import/export functionality
- `BookingProduct` - Booking product types
- `Notification` - System notifications

### Key Patterns

**Repository Pattern:** Each package typically includes:
- `Models/` - Eloquent models with contracts
- `Repositories/` - Data access layer
- `Contracts/` - Interface definitions

**Service Providers:** Each package registers via:
- `ModuleServiceProvider.php` - Package registration
- `{Package}ServiceProvider.php` - Main service provider
- `EventServiceProvider.php` - Event/listener bindings (if applicable)

**Configuration:** Package configs in `src/Config/` directories with specific configs like:
- `paymentmethods.php` - Payment method configurations
- `product_types.php` - Product type definitions
- `system.php` - System configuration options

### Frontend Architecture
- **Admin Panel:** Vue.js-based with Vite for asset compilation
- **Shop Frontend:** Blade templates with optional Vue.js components
- **Multi-theme Support:** Theme packages with customizable layouts
- **Asset Pipeline:** Vite with Laravel plugin for modern asset compilation

### Database Architecture
- Migration files in individual package `Database/migrations/` directories
- Seeders for sample data in `Database/seeders/` directories
- Multi-locale support with translation tables following Laravel Translatable pattern

### Testing Structure
- Feature tests for HTTP endpoints and business logic
- Unit tests for individual components and utilities  
- Test cases extend package-specific base test classes
- Database transactions used for test isolation

## Development Guidelines

### Code Style
- Follow Laravel PSR-12 coding standards enforced by Pint
- Use repository pattern for data access
- Implement contracts/interfaces for major components
- Follow package naming convention: `Webkul\{PackageName}`

### Database
- Use Laravel migrations for schema changes
- Follow naming conventions: `{table}_table.php` for migrations
- Implement proper foreign key relationships
- Use soft deletes where appropriate

### Configuration
- Store package-specific configs in `src/Config/` directories
- Use system configuration for user-configurable settings
- Register configurations in service providers

### Localization
- Support multiple locales with translation files in `lang/` directories
- Use Laravel's translation system with proper key structures
- Implement translatable models using Astrotomic/laravel-translatable package

### API Development  
- RESTful API routes typically in `routes/rest-routes.php`
- Use Laravel Sanctum for API authentication
- Follow JSON API response standards

This modular architecture allows for easy customization, extension, and maintenance of the eCommerce platform while following Laravel best practices.