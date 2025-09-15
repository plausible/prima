# Contributing to Prima

Thank you for your interest in contributing to Prima! We welcome contributions from the community.

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Set up the development environment:
   ```bash
   mix setup                # Full setup (deps, assets setup, assets build)
   ```

## Development Workflow

### Running the Demo

```bash
mix phx.server          # Start development server
```

Visit `http://localhost:4000/demo` to see all components in action and test your changes.

### Testing

```bash
mix test               # Run all tests (includes ExUnit and Wallaby tests)
```

The test suite includes both unit tests and comprehensive browser-based integration tests using Wallaby to ensure all interactive behaviors work correctly. Due to the interactive nature of Prima components, prefer Wallaby tests over unit tests for component testing.

### Building Assets

```bash
mix assets.build       # Build assets for development
```

## Making Changes

1. Create your feature branch (`git checkout -b feature/amazing-feature`)
2. Make your changes following the project's conventions:
   - Follow the existing code style and patterns
   - Ensure components are unstyled by default
   - Maintain accessibility standards (ARIA attributes, focus management, keyboard navigation)
   - Add appropriate tests (preferably Wallaby tests for interactive components)
3. Run the test suite to ensure nothing is broken
4. Commit your changes (`git commit -am 'Add amazing feature'`)
5. Push to your branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## Testing Strategy

- **ExUnit tests** for simple component logic and rendering
- **Wallaby tests** for complex UI interactions and components with JavaScript behavior
- Components with heavy JavaScript integration, DOM manipulation, or keyboard navigation should have Wallaby tests

## Pull Request Process

1. Ensure your code follows the existing patterns and conventions
2. Add tests for new functionality
3. Update documentation if necessary
4. Ensure all tests pass
5. Your PR will be reviewed by maintainers

## Questions?

If you have questions about contributing, feel free to open an issue for discussion.
