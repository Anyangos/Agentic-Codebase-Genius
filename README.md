# Agentic Codebase Genius

Agentic Codebase Genius is a multi-agent system designed to automatically generate concise, detailed and well-structured documentations for Giithub repositories. It leverages Jac(Jaseci), AI-driven agents, and a Stremlit frontend to simplify understanding, onboarding and collaboration for any codebase.

## Getting started 

### Prerequisites

- Python 3.8+
- Jaseci (The jac runtime environment)
- Git (for cloning the repositories)
- An LLM API key (eg. Gemini or OpenAI) for AI-powered summarization

1. **Clone the Repository**

    ```bash
    git clone 
    cd Agentic-Codebase-Genius
    ```
2. **Setup the Jaseci/Python Environment:**

    * It is highly recommended to use a virtual environment:
        ```bash
        python3 -m venv venv
        source venv/bin/activate  # On Linux/macOS
        # venv\Scripts\activate   # On Windows
        ```
    * Install **Jaseci** and any other Python dependencies:
        ```bash
        pip install jaclang streamlit requests jac-cloud
        # pip install -r requirements.txt (if available)
        ```

3. **Configure Environmnet Variables:**

    * Create a .env file in the root folder.
    * Add your LLM API key here, e,g:

    ```bash
    GEMINI_API_KEY=your_api_key_here
    ```
    * Ensure .env is added to .gitignore to prevent exposing your key.

## Running the Application

 **Build and Run the Jac Server:**
    In the first terminal, run the command:

    ```bash
    jac serve  codebase.jac
    ```

    This command will launch the backend server.

4. **Build and Run the Frontend**
    In a separate terminal, run the command:

    ```bash
    streamlit run app.py
    ```

    * This opens a browser-based interface where you can:
        - Upload GitHub repositories
        - Generate structured documentation automatically
        - View code relationships, function calls, and module       hierarchies visually

## Features 

    **Automated Documentation:** Generates clear, concise, and structured documentation for Python, JavaScript, and other supported languages.

    **Code Relationship Analysis:** Shows function calls, class hierarchies, and data flows.

    **Interactive Frontend:** Streamlit-based UI for uploading code and visualizing documentation.

    **Multi-Agent AI:** Uses Jac agents to intelligently parse and summarize codebases.

    **Environment-Safe:** Stores sensitive API keys in .env and isolates dependencies via a virtual environment.