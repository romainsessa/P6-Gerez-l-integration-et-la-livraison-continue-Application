#!/bin/bash

TESTS_RESULTS_DIR="test-results"

if [ -d "$TESTS_RESULTS_DIR" ]; then
    rm -rf "$TESTS_RESULTS_DIR"
fi

mkdir -p "$TESTS_RESULTS_DIR"

EXIT_CODE=0

if [ -f "build.gradle" ]; then
    echo  "Java backend project detected."
    if [ ! -x "./gradlew" ]; then
        chmod +x gradlew
    fi

    ./gradlew clean test
    EXIT_CODE=$?

    if [ -d "build/test-results/test" ]; then
        echo "Copying Java tests reports."
        cp build/test-results/test/*.xml "$TESTS_RESULTS_DIR/" 
    else
        echo "No test reports found."
        EXIT_CODE=1
    fi

elif [ -f "package.json" ]; then
    echo  "Angular frontend project detected."

    rm -rf reports

    if [ ! -d "node_modules" ]; then
        npm ci
    fi
    npm test -- --watch=false --browsers=ChromeHeadless
    EXIT_CODE=$?

     if [ -d "reports" ]; then
        cp reports/*.xml "$TESTS_RESULTS_DIR/"
        echo "Copying Angular tests reports."
    else
        echo "No test reports found."
        EXIT_CODE=1
    fi

else 
    echo "Unsupported project type."
    exit 1
fi

if [ -z "$(ls -A $TESTS_RESULTS_DIR)" ]; then
   echo "$TESTS_RESULTS_DIR directory is empty."
   EXIT_CODE=1
fi

if [ $EXIT_CODE -eq 0 ]; then
    echo "Tests executed successfully."
else
    echo "Test execution failed (exit code: $EXIT_CODE)."
fi

exit $EXIT_CODE