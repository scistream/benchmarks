*** Settings ***
Documentation     Tests for various tunnel configurations in the SciStream benchmarking system
...               Note: The tls-server SSH service is exposed on host port 2223.
Library           OperatingSystem
Library           Process
Library           RequestsLibrary
Library           String
Library           Collections
Library           DateTime

Suite Setup       Setup All Containers    # Start all containers at the beginning
Suite Teardown    Teardown Containers    # Clean up all containers at the end

*** Variables ***
${TEST_FILE}      10MB.bin
${OUTPUT_FILE}    /tmp/downloaded_file.bin
${BASE_URL}       http://localhost
${SERVER_URL}     http://localhost:8000
${HASH_COMMAND}   md5sum ${OUTPUT_FILE}
${EXPECTED_MD5}   aaa10722e5abc1f7c2df44c23caa1f2c  # Hardcoded MD5 for 10MB.bin
${DOCKER_COMPOSE_PATH}    ..    # Path to the docker-compose.yml (relative to tests directory)

*** Test Cases ***
Test Direct Connection
    [Documentation]    Test direct connection to the server without any tunnel
    [Setup]    Test Setup
    ${port} =    Set Variable    8000
    ${url} =    Set Variable    ${BASE_URL}:${port}/${TEST_FILE}
    Download And Verify File    ${url}    "Direct connection (port ${port})"
    [Teardown]    Test Teardown
    
Test TLS 1.3 Tunnel
    [Documentation]    Test connection through TLS 1.3 tunnel
    [Setup]    Test Setup
    ${port} =    Set Variable    9000
    ${url} =    Set Variable    ${BASE_URL}:${port}/${TEST_FILE}
    Download And Verify File    ${url}    "TLS 1.3 tunnel (port ${port})"
    [Teardown]    Test Teardown

Test TLS 1.2 NULL Cipher
    [Documentation]    Test connection through TLS 1.2 with NULL cipher
    [Setup]    Test Setup
    ${port} =    Set Variable    9001
    ${url} =    Set Variable    ${BASE_URL}:${port}/${TEST_FILE}
    Download And Verify File    ${url}    "TLS 1.2 NULL cipher (port ${port})"
    [Teardown]    Test Teardown

Test SSH Port Forwarding
    [Documentation]    Test connection through SSH port forwarding
    [Setup]    Test Setup
    ${port} =    Set Variable    7000
    ${url} =    Set Variable    ${BASE_URL}:${port}/${TEST_FILE}
    Download And Verify File    ${url}    "SSH port forwarding (port ${port})"
    [Teardown]    Test Teardown

Test HAProxy TCP Proxy
    [Documentation]    Test connection through HAProxy TCP proxy
    [Setup]    Test Setup
    ${port} =    Set Variable    7100
    ${url} =    Set Variable    ${BASE_URL}:${port}/${TEST_FILE}
    Download And Verify File    ${url}    "HAProxy TCP proxy (port ${port})"
    [Teardown]    Test Teardown

Test IPTables NAT
    [Documentation]    Test connection through pure iptables NAT
    [Setup]    Test Setup
    ${port} =    Set Variable    7400
    ${url} =    Set Variable    ${BASE_URL}:${port}/${TEST_FILE}
    Download And Verify File    ${url}    "IPTables NAT (port ${port})"
    [Teardown]    Test Teardown

*** Keywords ***
Setup All Containers
    Log    Setting up all containers for testing
    ${result} =    Run Process    cd ${DOCKER_COMPOSE_PATH} && docker-compose down    shell=True
    Log    ${result.stdout}
    ${result} =    Run Process    cd ${DOCKER_COMPOSE_PATH} && docker-compose up -d    shell=True
    Log    ${result.stdout}
    # Wait for containers to fully start
    Sleep    15s
    Log    All containers started and ready
    Log    Using hardcoded MD5 value: ${EXPECTED_MD5}

Teardown Containers
    Log    Stopping all containers
    ${result} =    Run Process    cd ${DOCKER_COMPOSE_PATH} && docker-compose down    shell=True
    Log    ${result.stdout}

Test Setup
    Remove File    ${OUTPUT_FILE}

Test Teardown
    Remove File    ${OUTPUT_FILE}

Download And Verify File
    [Arguments]    ${url}    ${tunnel_name}
    Log    Downloading from ${url} using ${tunnel_name}
    
    # Time the download with microsecond precision
    ${start_time} =    Get Time    epoch
    Create Session    tunnel_session    ${url}
    ${response} =    GET On Session    tunnel_session    ${url}    expected_status=200
    
    # Save the content to a file
    Create Binary File    ${OUTPUT_FILE}    ${response.content}
    ${end_time} =    Get Time    epoch
    ${download_time} =    Evaluate    ${end_time} - ${start_time}
    
    # Verify the file integrity
    ${result} =    Run Process    md5sum ${OUTPUT_FILE}    shell=True
    ${md5} =    Get Line    ${result.stdout}    0
    ${actual_md5} =    Set Variable    ${md5.split()[0]}
    
    # Calculate download speed with protection against division by zero
    ${file_size} =    Get Length    ${response.content}
    ${adjusted_time} =    Evaluate    max(${download_time}, 0.001)  # Ensure minimum time of 1ms
    ${speed_mbps} =    Evaluate    (${file_size} * 8) / (${adjusted_time} * 1000000)
    
    # Log the results
    Log    Download completed for ${tunnel_name} in ${download_time} seconds
    Log    Downloaded file size: ${file_size} bytes
    Log    Download speed: ${speed_mbps} Mbps
    
    # Assert that the downloaded file is correct
    Should Be Equal As Strings    ${actual_md5}    ${EXPECTED_MD5}    
    ...    Downloaded file through ${tunnel_name} has incorrect MD5 hash
    
    Log    File integrity verified for ${tunnel_name}
    
    RETURN    ${download_time}
