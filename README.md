This project has been created as part of the 42 curriculum by hboutale

# Description

this project focuses about learning containerization using docker and docker compose.
goal is design and deploy multi-service application.

The project consists of setting up several interconnected services such as a web server, a database, and supporting components each running in its own container. Using Docker Compose, these services are orchestrated to communicate efficiently within a defined network.

the project demonstrates key concepts including container lifecycle management, service orchestration, networking between containers, and environment configuration. The overall objective is to build a structured, scalable, and maintainable system that reflects real-world deployment practices.

# Instructions

To build and run this project, ensure that Docker and Docker Compose are installed on your system.

## Installation

Clone the repository and navigate to the project directory:

```sh
git clone <repository_url>
cd <project_directory>
```

## Usage

All operations are managed through the Makefile:

### Build and start the services:

```sh
make up
```

### Stop the services:

```sh
make down
```

### Rebuild the project:

```sh
make re
```

### View logs:

```sh
make logs
```

# Resources

- [Docker Resources](https://docs.docker.com/get-started/resources/)
- [Docker Curriculum](https://docker-curriculum.com/)
- [Docker mooc](https://courses.mooc.fi/org/uh-cs/courses/devops-with-docker/chapter-1)
- [docker training course for the absolute beginner](https://learn.kodekloud.com/courses/docker-training-course-for-the-absolute-beginner)
