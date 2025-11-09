import from byllm.llm { Model}
import os;
import subprocess;

# Global LLM model
glob llm = Model(model_name="gemini/gemini-2.0-flash", verbose=True);

# Node: FileManager (local, non-LLM)
node FileManager {
    has repo_url: str = "";
    has repo_path: str = "";

    # Clone the repository
    def clone_repo() -> str {
        # Create repo path if it does not exist
        if not os.path.exists("./repos") {
            os.makedirs("./repos");
        }

        repo_name = self.repo_url.split("/")[-1].replace(".git", "");
        self.repo_path = "./repos/" + repo_name;

        # Check if repos path exists
        if os.path.exists(self.repo_path){
            return self.repo_path;
        }

        # Clone the repo using command 'git clone'
        try {
            subprocess.run(["git", "clone", self.repo_url, self.repo_path], check=True);
            return self.repo_path;
        }

        except Exception as e {
            report "Clone failed: " + str(e);
            return "Failed to clone repository.";
        }
    }

        # List files recursively
    def list_files(base_path: str) -> list {
        all_files = [];
        entries = os.listdir(base_path);

        # Iterate over all entries both folders and files 
        for e in entries {
            full_path = os.path.join(base_path, e);

            # Check if an entry is a directory and creates paths for each file and append to all_files
            if os.path.isdir(full_path) {
                sub_files = self.list_files(full_path); # Recursion
                for sf in sub_files {
                    all_files.append(os.path.join(e, sf));
                }
            } else {
                all_files.append(e);
            }
        }
        return all_files;
    }

    # Read file content
    def read_file(file_path: str) -> str {
        try {
            with open(file_path, "r", encoding="utf-8") as f {
                content = f.read();
            }
            return content;
        }
        
        except Exception as e {
            report "Failed to read " + file_path + ": " + str(e);
            return "";
        }
    }

    # Save text content to a file
    def save_output(content: str, output_path: str) -> str {
        abs_path = os.path.abspath(output_path); # from root
        dir_path = os.path.dirname(abs_path);

        # If directory does not exist create
        if not os.path.exists(dir_path) {
            os.makedirs(dir_path, exist_ok=True);
        }

        try {
            with open(abs_path, "w", encoding="utf-8") as f {
                f.write(content);
            }
            report "Documentation saved at: " + abs_path;
            return abs_path;
        }
        
        except Exception as e {
            report "Failed to save file: " + str(e);
            return "";
        }
    }
}

# Node: RepoMapper (1st LLM powered node)
node RepoMapper {
    def map_repo_structure(files: list[str]) -> str by llm();
    def summarize_readme(readme_content: str) -> str by llm(); 
}

sem RepoMapper.map_repo_structure = """
Given a list of file paths, produce a concise and well-structured Markdown document with the following headings 
and their corresponding content:

## Repository Structure
- Present only the meaningful parts of the repository tree (code, configs, docs, tests, etc.).
- Exclude irrelevant or hidden system folders such as .git, .vscode, __pycache__, node_modules, dist, build, or virtual environments.
- Use icons 📁 for folders and 📄 for files.
- Keep it minimal but readable.


## Languages Detected
- List the programming or markup languages found in the repo.

## Entry Points
- List possible main files, e.g. main.py, app.js, index.html.
""";

sem RepoMapper.summarize_readme = """
Given README text, produce a concise project overview describing purpose, key features, and usage.
Return plain text summary with the following heading: 

## Overview
""";

# Node: CodeAnalyzer (LLM)
node CodeAnalyzer {
    def analyze_code(file_content: str, filename: str) -> str by llm();
    def build_context_graph(files_data: list[str]) -> str by llm();
}

sem CodeAnalyzer.analyze_code = """
Analyze the provided source code to identify:
- Programming language
- Functions and their purposes
- Classes and their roles
- Imports or dependencies

Return JSON:
{
  "filename": "<filename>",
  "language": "<language>",
  "summary": "<short summary>",
  "functions": ["funcA()", "funcB()"],
  "classes": ["ClassX", "ClassY"],
  "imports": ["module1", "module2"]
}
""";

sem CodeAnalyzer.build_context_graph = """
You are a software architecture visualizer.

Given a list of analyzed file data (each element is a JSON object containing filename, programming language, summary, functions, classes, and imports), produce a **Markdown document** starting with the header:

## Code Context Graph

Then include the following sections:

### Summary
- Write a concise natural-language summary describing how the files interact and depend on each other.
- Mention important classes, functions, and imports.
- Explain the overall system architecture (e.g., frontend vs backend, data flow, dependencies).

### Dependency Diagram (Text-Based)
- Instead of Mermaid, generate a visually clear **ASCII or emoji-based flowchart** that renders correctly in plain text.
- Use indentation and arrows (→) or emoji symbols (🡒, 🔹, 🟩, 🟦, ⚙️, etc.) to show relationships between files and dependencies.
""";

# Node: DocGenie (LLM)
node DocGenie {
    def generate_documentation(repo_summary: str, structure_json: str, ccg_json: str) -> str by llm();
}

sem DocGenie.generate_documentation = """
You are DocGenie, an expert technical writer specializing in software documentation.

Given the following inputs:
- repo_summary: A plain text overview of the repository (from summarize_readme).
- structure_json: The Markdown representation of the folder/file structure (from map_repo_structure).
- ccg_json: The Markdown output of code relationships including Mermaid diagrams (from build_context_graph).

Produce a **professional, well-structured Markdown document** with the following sections in order:

## Project Overview
- Use the `repo_summary` to describe the purpose, key features, and usage of the project.
- Keep it concise and clear.
- Include any inferred high-level notes that help a developer understand what the project does.

## Repository Structure
- Insert the `structure_json` content here.
- Ensure nested folders/files are correctly indented.
- Include icons for folders (📁) and files (📄).
- Highlight any detected programming languages and entry points.

## Installation & Usage
- Infer installation steps from the project content if not explicitly provided.
- Include dependencies, setup instructions, and commands to run the project.
- Highlight any required environment variables, configuration files, or setup notes.

## Key Functions
- Summarize the main modules, classes, and functions based on `ccg_json` and `analyze_code` outputs.
- Include brief descriptions of their purpose.
- Organize content in a readable list or table format.

## Code Relationships
- Insert the `ccg_json` content here.
- Include the summary of how files depend on each other.
- Embed the Mermaid diagram showing file relationships.
- Ensure the diagram is correctly formatted to render in Markdown.

Requirements:
- Output must be valid Markdown and fully renderable.
- Maintain clear headings and logical flow.
- Use bullet points, code blocks, or tables where appropriate to enhance readability.
- Keep all content concise, professional, and developer-friendly.
""";

# Walker: GenerateRepoDoc
walker GenerateRepoDoc {
    has repo_url: str = "";

    obj __specs__ {
        static has auth: bool = False;
        static has methods: list[str] = ["post"];
        static has body: dict[str, str] = { "repo_url": "string" };
    }

    can run with entry {
        # FileManager operations 
        fm = spawn FileManager;
        fm.repo_url = self.repo_url;
        repo_path = fm.clone_repo();
        if repo_path.startswith("Failed") {
            report "Stopping: cloning failed.";
            return;
        }

        files = fm.list_files(repo_path);

        # Read the first README file content
        readme_files = ["README.md", "readme.md", "docs/README.md"];
        readme_content = "";
        for rf in readme_files {
            full_path = os.path.join(repo_path, rf);
            if os.path.exists(full_path) {
                # Read the content of the readme and hold onto it
                readme_content = fm.read_file(full_path);
                break;
            }
        }

        # LLM-powered summary & structure
        mapper = spawn RepoMapper;
        repo_summary = "";
        # if readme file read is not empty, it summarizes 
        if readme_content != "" {
            repo_summary = mapper.summarize_readme(readme_content);
            report repo_summary;
        }

        structure_json = mapper.map_repo_structure(files);
        report "Repo Structure JSON: " + structure_json;

        # Analyze code files
        analyzer = spawn CodeAnalyzer;
        analyses = []; # to collect JSON outputs from analyzing each file.
        for f in files {
            if any(f.endswith(ext) for ext in [".py", ".jac", ".js", ".html"]) {
                content = fm.read_file(os.path.join(repo_path, f));
                if content.strip() != "" {
                    analysis = analyzer.analyze_code(content, f);
                    analyses.append(analysis);
                }
            }
        }

        report "Files found: " + str(files);
        report "Analyses collected: " + str(analyses);

        # Calls CodeAnalyzer.build_context_graph()
        ccg_json = analyzer.build_context_graph(analyses);

        # Display ccg contents
        report ccg_json;

        # Generate Markdown documentation
        docgen = spawn DocGenie;
        docs_md = docgen.generate_documentation(repo_summary, structure_json, ccg_json);

        # Save output
        repo_name = os.path.basename(repo_path);
        output_path = f'./outputs/{repo_name}/docs.md';
        final_output = fm.save_output(docs_md, output_path);
    }
}