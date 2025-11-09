import streamlit as st
import requests

# 🎨 Page config
st.set_page_config(
    page_title="Codebase Genius – AI Documentation Generator",
    page_icon="🤖",
    layout="centered",
)

# 💅 Custom CSS (Dark Blue Theme + Green Button + Hover Effect)
st.markdown("""
<style>
/* Main App Styling */
body, .stApp {
    background-color: #0a1a2f;  /* Dark navy blue */
    color: #ffffff;
    font-family: "Inter", sans-serif;
}

/* Page Title Container */
.header-container {
    display: flex;
    justify-content: center;
    align-items: center;
    margin-bottom: 1rem;
    transition: all 0.3s ease-in-out;
}

.header-container:hover h1 {
    color: #7CFC00;  /* Light green on hover */
    transform: scale(1.05);
}

/* Page Title */
h1 {
    color: #ffffff;
    font-weight: 700;
    margin: 0;
}

/* Subtitle */
.subtitle {
    text-align: center;
    color: #a0e0a0;  /* soft greenish */
    margin-bottom: 2rem;
}

/* Input Field */
.stTextInput>div>div>input {
    background-color: #112240;  /* slightly lighter blue */
    color: #ffffff;
    border-radius: 8px;
    border: 1px solid #1f3a5f;
}

/* Button Styling */
.stButton>button {
    background-color: #2ecc71;  /* green */
    color: #ffffff;
    font-weight: 600;
    border: none;
    border-radius: 8px;
    padding: 0.5rem 1.5rem;
    transition: all 0.2s ease-in-out;
}

.stButton>button:hover {
    background-color: #27ae60;  /* darker green on hover */
    transform: scale(1.03);
}

/* Output Box */
.output-box {
    background-color: #112240;  /* slightly lighter blue */
    padding: 1.5rem;
    border-radius: 12px;
    margin-top: 1.5rem;
    color: #ffffff;
    line-height: 1.6;
}

/* Code Styling */
code, pre {
    color: #7FDBFF;  /* light cyan for code */
}
</style>
""", unsafe_allow_html=True)

# 🧠 Header
st.markdown('<div class="header-container"><h1>🤖 Code Genius</h1></div>', unsafe_allow_html=True)
st.markdown('<p class="subtitle">AI-Powered Repository Documentation Generator</p>', unsafe_allow_html=True)
st.markdown("---")

# 🔗 Input for GitHub URL
repo_url = st.text_input("Repository URL", placeholder="e.g. https://github.com/username/repository")

# ⚙️ Button to trigger generation
if st.button("Generate Documentation"):
    if not repo_url.strip():
        st.warning("Please enter a repository URL.")
    else:
        with st.spinner(f"Generating documentation for {repo_url} ..."):
            try:
                response = requests.post(
                    "http://localhost:8000/walker/GenerateRepoDoc",
                    json={"repo_url": repo_url},
                    timeout=300
                )

                if response.status_code == 200:
                    data = response.json()
                    markdown_output = "\n".join(data.get("reports", [])) or "No documentation generated."

                    # ✅ Render Markdown safely
                    st.markdown("---")
                    st.markdown("### Generated Documentation")
                    st.markdown(f"<div class='output-box'>", unsafe_allow_html=True)
                    st.markdown(markdown_output)
                    st.markdown("</div>", unsafe_allow_html=True)
                else:
                    st.error(f"Server returned status {response.status_code}")
            except Exception as e:
                st.error(f"Error: {e}")
