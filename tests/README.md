# Tunnel Tests

Tests for verifying tunnel configurations functionality.

## Running Tests

To run the tests, simply execute the following commands from the tests directory:

```bash
source venv/bin/activate
robot --outputdir results tunnel_tests.robot

```

The Robot Framework test will:
1. Start all containers at the beginning of the test suite
2. Download test files through each tunnel 
3. Verify file integrity
4. Measure and report performance
5. Clean up after all tests are complete

Results are saved in the results directory with detailed HTML reports that can be viewed in any browser.
