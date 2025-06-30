# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Set a working directory inside the container for our operations.
# /opt is a common location for optional application software packages.
WORKDIR /opt

# Step 1: Install necessary tools:
# - wget: to download the tar.gz file
# - tar: to extract the tar.gz file
# - default-jdk: Apache Tomcat requires a Java Development Kit (JDK) to run.
#                This installs OpenJDK 11, which is compatible with Tomcat 9.
RUN apt update && apt install -y wget tar default-jdk

# Step 2: Define variables for the Tomcat download
ARG TOMCAT_VERSION="9.0.106"
ARG TOMCAT_DOWNLOAD_URL="https://dlcdn.apache.org/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
ARG TOMCAT_ARCHIVE_NAME="apache-tomcat-${TOMCAT_VERSION}.tar.gz" # The actual name of the downloaded file
ARG EXTRACTED_FOLDER_NAME="apache-tomcat-${TOMCAT_VERSION}"       # The folder name after extraction
ARG DESIRED_FOLDER_NAME="apache-tomcat"                           # The final folder name you want

# Step 3: Download the Tomcat archive
# -O: saves the file with the specified name in the current directory.
RUN wget "${TOMCAT_DOWNLOAD_URL}" -O "${TOMCAT_ARCHIVE_NAME}"

# Step 4: Extract the Tomcat archive
# This will extract the contents into the folder specified by EXTRACTED_FOLDER_NAME (e.g., /opt/apache-tomcat-9.0.106/)
RUN tar -xzf "${TOMCAT_ARCHIVE_NAME}"

# Step 5: Rename the extracted folder to your desired name (apache-tomcat)
# mv is used to move/rename files and directories.
# This makes the path consistent /opt/apache-tomcat/
RUN mv "${EXTRACTED_FOLDER_NAME}" "${DESIRED_FOLDER_NAME}"

# Step 6: Clean up the downloaded archive to keep the image size small
RUN rm "${TOMCAT_ARCHIVE_NAME}"

COPY student.war /opt/apache-tomcat/webapps/

COPY context.xml /opt/apache-tomcat/conf/context.xml
ADD https://s3-us-west-2.amazonaws.com/studentapi-cit/mysql-connector.jar /opt/apache-tomcat/lib/

# OpenJDK 11 usually installs to /usr/lib/jvm/java-11-openjdk-amd64
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Expose the default Tomcat HTTP connector port (8080)
EXPOSE 8080

# Command to run when the container starts
# This runs Tomcat's startup script in the foreground,
# so the container keeps running as long as Tomcat is active.
CMD ["/opt/apache-tomcat/bin/catalina.sh", "run"]
