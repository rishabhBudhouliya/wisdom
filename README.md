## Inspiration
The digital mental health ecosystem has never found the right product for therapy. With the advent of reasoning models and chain of thought tokens, we believe AI agents are sufficiently perceptive to have a conversation and explore deep issues within self
## What it does
An AI agent that talks like a father, or a mentor.
## How we built it
We use the OpenAI o1 model for reasoning, a RAG to derive a context related to knowledge coming from authors from the 60s (like Freud, Oscar Wilde or Frank Herbert)
Our app is built with Swift on iOS.

## Challenges we ran into
We built this app with pure api interactions without caching, memory or persistence. That introduces dependency on network delays and a loss of seamless user experience. Also, we did not have enough time to fine tune and apply reinforcement learning on our models.

## Accomplishments that we're proud of
Our app offers a safe space to talk to the user

## What we learned
Using APIs is easy, building an experience is hard.

## What's next for Wisdom
Using fine-tuned models and reinforcement learning to build user personas and offer their personality tailored therapy experience
