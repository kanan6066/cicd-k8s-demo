# CI/CD Pipeline for Containerized Web Application

An automated CI/CD pipeline that builds, tests, scans, and deploys a containerized Node.js/Express application to Kubernetes — triggered automatically on every push to `main`.

## Architecture
Push to main
│
▼
GitHub Actions (build-test-scan)
│
├── Run app tests
├── Build Docker image (multi-stage, layer-cached)
├── Scan image with Trivy (vulnerability scanning)
└── Push image to GitHub Container Registry (GHCR)
│
▼
GitHub Actions (deploy) — self-hosted runner
│
└── kubectl set image → rolling update on Kubernetes
│
▼
Kubernetes cluster
├── Deployment (3 pods, auto-healing via readiness/liveness probes)
├── Service (LoadBalancer — distributes traffic across pods)
└── HorizontalPodAutoscaler (scales 3→10 pods based on CPU)Code quality is also continuously analyzed by **SonarQube Cloud** on every push (Security, Reliability, and Maintainability ratings).

## Tech Stack

- **App**: Node.js + Express
- **Containerization**: Docker (multi-stage builds, non-root user, health checks)
- **CI/CD**: GitHub Actions (cloud-hosted build/test/scan, self-hosted runner for deploy)
- **Container Registry**: GitHub Container Registry (GHCR)
- **Orchestration**: Kubernetes (Deployment, Service, HPA)
- **Security Scanning**: Trivy (container vulnerability scanning), SonarQube Cloud (static code analysis)

## Key Features

- **Automated pipeline**: every push to `main` triggers build → test → scan → push → deploy, with no manual steps
- **Docker layer caching**: dependency installation is cached separately from source code, so unchanged dependencies are never reinstalled
- **Multi-container orchestration**: 3+ replicas managed by Kubernetes, load-balanced via a Service
- **Auto-scaling**: HorizontalPodAutoscaler scales pods 3→10 based on CPU utilization (70% threshold)
- **Self-healing**: readiness/liveness probes on `/health` ensure Kubernetes only routes traffic to healthy pods
- **Security scanning**: Trivy scans every built image for CRITICAL/HIGH vulnerabilities; SonarQube Cloud continuously analyzes code quality

## Project Structure
.
├── app/ # Node.js/Express application
│ ├── index.js
│ └── package.json
├── k8s/ # Kubernetes manifests
│ ├── deployment.yaml
│ ├── service.yaml
│ └── hpa.yaml
├── .github/workflows/
│ └── ci-cd.yml # GitHub Actions pipeline
└── Dockerfile # Multi-stage build
## Running Locally

```bash
docker build -t myapp:latest .
docker run -d -p 3000:3000 myapp:latest
curl http://localhost:3000
curl http://localhost:3000/health
```

## Deploying to Kubernetes

```bash
kubectl apply -f k8s/
kubectl get pods
kubectl port-forward service/myapp-service 8080:80
```

## Live Image

Pull the built image directly from GHCR:
```bash
docker pull ghcr.io/kanan6066/cicd-k8s-demo:latest
```

## Code Quality

View live analysis on [SonarQube Cloud](https://sonarcloud.io/project/overview?id=kanan6066_cicd-k8s-demo).

