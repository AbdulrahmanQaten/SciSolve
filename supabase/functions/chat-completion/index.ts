import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// ============================================
// 🧠 MAIN HANDLER
// ============================================
serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { messages, aiStyle } = await req.json();
    console.log(
      "📥 Payload Sample:",
      JSON.stringify(messages).substring(0, 500)
    );
    const style = aiStyle || "balanced";

    // STRICT IDENTITY & STYLE PROMPT
    const basePrompt = `You are **SciSolve**, an elite scientific AI tutor developed by **SciTeam**.

### 🆔 IDENTITY
- **Name**: SciSolve
- **Developer**: SciTeam
- **Nature**: You are a helpful, precise, and friendly AI assistant specialized in Math, Science, and Coding.
- **Origin Rule**: If asked about your creator, simply state: "I am SciSolve, developed by SciTeam." Do not mention other companies or models.

### 🧠 PROBLEM SOLVING PROTOCOL (RIGOROUS)
**When presented with a problem, you MUST follow this structure:**

1.  **📊 Deconstruct**:
    *   **Extract Givens**: List all known values/variables explicitly (e.g., $v_0 = 0, t = 10s$).
    *   **Identify Goal**: What exactly needs to be found?
    *   **Completeness Check**: Is any data missing?
        *   🔴 **IF DATA MISSING**: STOP. Do not assume values. Ask the user for clarification.
        *   🟢 **IF COMPLETE**: Proceed.

2.  **📜 Principles & Laws**:
    *   State the relevant theorem, law, or formula *before* using it (e.g., "Using Newton's Second Law: $F=ma$").

3.  **🪜 Step-by-Step Execution**:
    *   Substitute values into the formula.
    *   Show the calculation steps clearly.
    *   Keep units consistent throughout.

4.  **✅ Final Answer**:
    *   State the result clearly with units.
    *   Briefly verify if the answer makes physical sense.

### 🚫 CRITICAL LANGUAGE RULE (ZERO TOLERANCE)
1.  **DETECT** the user's language immediately.
2.  **RESPOND ONLY** in that specific language.
    *   If Arabic -> Use **Pure Arabic**. NO English/Russian/Asian characters.
    *   If English -> Use English.
3.  **ANTI-HALLUCINATION**:
    *   Do NOT invent words.
    *   Do NOT switch scripts (e.g. don't write "الميكانيك-ism").
    *   **NEVER** use Cyrillic (Russian) or Thai/Chinese characters unless explicitly asked.

### 🚧 SCOPE ENFORCEMENT
- **ALLOWED**: Math, Physics, Chemistry, Biology, Computer Science, Coding, Engineering.
- **FORBIDDEN**: History, Politics, Literature, Religion, Entertainment, Cooking, etc.
- **ACTION**: If asked about forbidden topics, politely refuse: "I apologize, but I am specialized only in Science and Math." (in the user's language).

### 🔢 FORMATTING
- **Math**: Use LaTeX ($\\dots$ or $$\\dots$$).
- **Tone**: Professional, Scientist-to-Scientist.`;

    let styleInstruction = "Balance detailed explanations with clarity.";
    if (style === "detailed")
      styleInstruction =
        "Provide comprehensive, deep explanations with extensive examples, proofs, and background context.";
    if (style === "concise")
      styleInstruction =
        "Be extremely concise. Provide the solution and minimal necessary steps. Avoid filler.";

    const finalSystemPrompt = `${basePrompt}\n\n### 🎨 RESPONSE STYLE: ${style.toUpperCase()}\n${styleInstruction}`;

    const apiKey = Deno.env.get("OPENROUTER_API_KEY");
    const hfKey = Deno.env.get("HF_TOKEN");

    if (!messages || !Array.isArray(messages))
      throw new Error("Messages array is required");
    if (!apiKey) throw new Error("OPENROUTER_API_KEY is not set");

    // ============================================
    // 🔀 ROUTING LOGIC: Qwen is primary
    // ============================================
    const hasImages = messages.some((m: any) => Array.isArray(m.content));
    let processedMessages = messages;
    
    let models = [
      "Qwen/Qwen2.5-VL-72B-Instruct",           // PRIMARY: HuggingFace (free, handles images and text beautifully)
      "tngtech/deepseek-r1t2-chimera:free",     // BACKUP 1: OpenRouter (text only, fast)
      "deepseek/deepseek-r1-0528:free",          // BACKUP 2: OpenRouter (text only, strongest)
    ];

    if (hasImages && !hfKey) {
       console.log("⚠️ Images detected but HF_TOKEN missing. Removing image parts for text-only fallbacks.");
       processedMessages = messages.map((msg) => {
         if (Array.isArray(msg.content)) {
           const textContent = msg.content.find((c: any) => c.type === 'text')?.text || "[Image omitted]";
           return { ...msg, content: textContent };
         }
         return msg;
       });
       models = models.filter(m => !m.includes('Qwen') || hfKey); // Remove Qwen if no HF key
    }

    // ============================================
    // 🚀 MODEL EXECUTION
    // ============================================
    let response;
    let usedModel;
    let lastError;

    for (const model of models) {
      try {
        console.log(`🔧 Trying model: ${model}`);

        let apiUrl = "https://openrouter.ai/api/v1/chat/completions";
        let apiToken = apiKey;
        let targetModel = model;

        // Route to Hugging Face if Qwen or deepseek-ai/ (HF models)
        if (
          (model.includes("Qwen") || model.startsWith("deepseek-ai/")) &&
          hfKey
        ) {
          console.log("⚡ Routing to Hugging Face");
          apiUrl = "https://router.huggingface.co/v1/chat/completions";
          apiToken = hfKey;
        }

        const routerMessages = processedMessages.map((msg) => ({
          role: msg.role ?? (msg.isUser ? "user" : "assistant"),
          content: msg.content,
        }));

        routerMessages.unshift({
          role: "system",
          content: finalSystemPrompt,
        });

        const requestBody = {
          model: targetModel,
          messages: routerMessages,
          stream: true,
        };

        const res = await fetch(apiUrl, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${apiToken}`,
            "HTTP-Referer": "https://scisolve.app",
            "X-Title": "SciSolve",
          },
          body: JSON.stringify(requestBody),
        });

        if (res.ok) {
          response = res;
          usedModel = model;
          console.log(`✅ Success with: ${model}`);
          break;
        } else {
          const data = await res.json();
          const err = data.error?.message || JSON.stringify(data);
          console.error(`❌ Model ${model} failed: ${err}`);
          lastError = err;
        }
      } catch (e) {
        lastError = e.message;
        console.error(`❌ Model ${model} error: ${e.message}`);
      }
    }

    if (!response) {
      throw new Error(`All models failed. Last error: ${lastError}`);
    }

    // ============================================
    // 📤 STREAM RESPONSE
    // ============================================
    const { body } = response;
    const reader = body.getReader();
    const decoder = new TextDecoder();
    const encoder = new TextEncoder();

    const stream = new ReadableStream({
      async start(controller) {
        let buffer = "";

        while (true) {
          const { done, value } = await reader.read();
          if (done) {
            controller.close();
            break;
          }

          buffer += decoder.decode(value, { stream: true });
          const lines = buffer.split("\n");
          buffer = lines.pop() || "";

          for (const line of lines) {
            const trimmed = line.trim();
            if (!trimmed.startsWith("data: ")) continue;
            if (trimmed === "data: [DONE]") continue;

            try {
              const json = JSON.parse(trimmed.substring(6));
              const content = json.choices?.[0]?.delta?.content;
              if (content) {
                const chunk = JSON.stringify({ text: content });
                controller.enqueue(encoder.encode(`data: ${chunk}\n\n`));
              }
            } catch (e) {
              // Ignore malformed chunks
            }
          }
        }
      },
    });

    return new Response(stream, {
      headers: {
        ...corsHeaders,
        "Content-Type": "text/event-stream",
        "Cache-Control": "no-cache",
        Connection: "keep-alive",
      },
    });
  } catch (error) {
    console.error("💥 Error:", error);
    return new Response(
      JSON.stringify({
        error: error.message,
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
