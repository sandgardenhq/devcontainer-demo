# Sandgarden Example Workflow

This is an example workflow that loads the CF-TriviaQA dataset and answers some questions based on it.
Then is checks the answers using an LLM-as-Judge pattern. In this example we use GPT-4o-mini to check the itself.

## 1. Create the workflow

```bash
sand workflows create --name trivia --description "An example workflow using GPT-4o-mini to answer questions from the CF-TriviaQA Dataset" --stages='[{"step":"answer-some-questions:latest"}]'
```

## 2. Create an OpenAI connector

```bash
sand connectors create openai --name="trivia-openai" --api-key="FILL_IN"
```

## 3. Create the step - answer some questions

```bash
cd /workspaces/sandgarden/workflow/steps/001_answer_some_questions && sand steps create docker --name=answer-some-questions --file=. --baseImage="python:3.12" --entrypoint="handler.handler" --connector trivia-openai --tag=latest --outputSchema "$(cat response_schema.json)" --cluster $(jq -r .cluster /workspaces/sandgarden/.devcontainer/.sandgarden/staticcfg.json)
```

## 4. Create Step 3 - check the answers

```bash
cd /workspaces/sandgarden/workflow/steps/002_check_your_work && sand steps create docker --name=check-your-work --file=. --baseImage="python:3.12" --entrypoint="handler.handler" --connector trivia-openai --outputSchema "$(cat output_schema.json)" --tag latest --inputSchema "$(cat input_schema.json)" --cluster $(jq -r .cluster /workspaces/sandgarden/.devcontainer/.sandgarden/staticcfg.json)
```

## 5. Update the workflow

```bash
sand workflows push --name trivia --description "An example workflow using GPT-4o-mini to answer questions from the CF-TriviaQA Dataset" --stages='[{"step":"answer-some-questions:latest"},{"step":"check-your-work:latest"}]'  --tag latest
```

## 6. Run it!

```bash
sand runs start --workflow=trivia:latest --cluster $(jq -r .cluster /workspaces/sandgarden/.devcontainer/.sandgarden/staticcfg.json)
```