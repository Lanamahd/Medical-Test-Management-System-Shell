# Medical Test Management System (Shell)

This project implements a **Medical Test Management System** written entirely in Shell scripting. The system is designed to manage and streamline the process of storing, retrieving, and managing medical test records through a command-line interface.

## Features
- **Record Management**: Add, update, and delete medical test records.
- **Search and Retrieval**: Search for specific records based on patient information or test details.
- **Command-Line Interface**: Fully functional CLI for user interaction.
- **Efficient and Lightweight**: Built using Shell scripting for portability and efficiency.

## Tech Stack
- **Shell Scripting**: 100% of the project is implemented in Shell.

## Getting Started

### Prerequisites
- A Unix-like operating system (Linux, macOS, etc.) with a Bash shell.
- Basic understanding of command-line operations.

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Lanamahd/Medical-Test-Management-System-Shell.git
   cd Medical-Test-Management-System-Shell

2. Ensure scripts have executable permissions:
   ```bash
    chmod +x *.sh

## Usage

1. Run the main script to start the management system:
   ```bash
   ./main.sh

2. Follow the on-screen instructions to perform operations like:

- Adding a new medical test record.
- Searching for existing records.
- Updating or deleting records.


## File Structure
/
├── main.sh                 # Entry point for the management system
├── add_record.sh           # Script for adding new test records
├── search_record.sh        # Script for searching test records
├── update_record.sh        # Script for updating test records
├── delete_record.sh        # Script for deleting test records
├── utils/                  # Utility scripts and helper functions
└── README.md               # Project documentation
