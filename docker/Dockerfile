FROM cimg/android:2025.11.1-ndk

# Install ninja-build for Vulkan shader compilation
USER root
RUN apt-get update && apt-get install -y ninja-build && rm -rf /var/lib/apt/lists/*
USER circleci

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]
