# Chess App Architecture Plan

## Section 1: Existing GO App — Bug Report & Analysis

### 1.1 Logic Bugs

#### Critical: `game.dart` — `playTurn()` returns `void` but caller expects `bool`
- **File:** `lib/models/game.dart` (the legacy, non-optimised version)
- **Line 15–20:** `void playTurn(int i, int j)` — returns nothing.
- **Usage in screen (`game_board_screen.dart` line 30):** `final success = _game.playTurn(i, j)` — this relies on a `bool` return value that only exists in `optimized_game.dart`.
- **Impact:** Assigning a `void`-returning function to a `bool` variable is a **compile-time error** in Dart with sound null-safety. The project only compiles today because `game_board_screen.dart` imports `optimized_game.dart` (which correctly returns `bool`). If that import were accidentally changed back to the legacy `game.dart`, the build would fail immediately — making this dual-class situation a maintenance hazard.

#### Ko-Rule Revert Bug (`board.dart`)
- **File:** `lib/models/board.dart`, lines 64–71.
- When a Ko violation is detected the code:
  1. Removes the newly placed stone ✅
  2. Restores captured stones ✅
  3. **Does NOT roll back `_capturedByBlack` / `_capturedByWhite` counters ❌**
- Captured stone counters silently go negative or accumulate phantom captures each time a Ko-rule move is attempted.

#### BFS Queue Duplicate Entries in `_floodFill` (`game.dart`)
- **File:** `lib/models/game.dart`, `_floodFill()` (lines 128–155).
- Cells are added to the queue without a "seen" check **before** enqueue. Only the `points.contains(p)` check after dequeue prevents duplicates, but the queue itself can grow to O(n⁴) for a full board — severe performance issue on 19×19.
- **Fix:** Add a `Set<Point> queued` and check it before enqueuing.

#### `_showBoardSize` Doesn't Close Parent Sheet
- **File:** `lib/screens/home_screen.dart`, `_showBoardSize()` (line 412).
- When the "Select Board Size" bottom sheet is shown from inside the "Select Game Mode" sheet, tapping a size pops only **one** sheet (`Navigator.pop(context)`), leaving the parent "Game Mode" sheet still visible on the navigation stack.

#### Double-Pass Race Condition
- **File:** `lib/screens/game_board_screen.dart`.
- There are **two** Pass buttons: one in `_buildGameInfo()` (line 293) and one in `bottomNavigationBar` (line 108). Both call `_game.pass()` independently. Rapidly tapping both in the same frame can trigger `isGameOver` checks out of order.

#### `isComputer` Flag Ignored
- **File:** `lib/screens/home_screen.dart`, `_showBoardSize()` (line 412).
- `isComputer` is passed to `_showBoardSize` but is never forwarded to `GameBoardScreen`. Both "vs Computer" and "vs Friend" launch exactly the same two-player local game. There is **no AI** of any kind.

### 1.2 UI / UX Issues

| Issue | Location | Details |
|---|---|---|
| Fake hardcoded game history | `home_screen.dart` lines 287–291 | "vs Player A", "vs Player B", "vs Player C" are static strings |
| Daily Challenge progress always 30% | `home_screen.dart` line 269 | `LinearProgressIndicator(value: 0.3, …)` is a constant |
| Developer Debug Menu exposed in production | `home_screen.dart` lines 31–57 | `Icons.bug_report` popup visible to all users |
| `BoardComparisonScreen` reachable from production UI | `home_screen.dart` line 39 | Performance-testing screen should not ship |
| No komi for white player | `optimized_game.dart` score logic | In GO, white receives 6.5 komi; totals are misleading without it |
| Score shown mid-game before territory is settled | `game_board_screen.dart` `_buildGameInfo()` | Territory calculation runs on every render; results are meaningless until game ends |

### 1.3 State Management / Architecture Issues

| Issue | Details |
|---|---|
| **Duplicate model classes** | `lib/models/game.dart` AND `lib/models/optimized_game.dart` are separate `Game` classes; `lib/models/board.dart` AND `lib/models/optimized_board.dart` are separate `Board` classes. Neither is deleted; dead code accumulates. |
| **Five board widgets** | `game_board.dart`, `fast_game_board.dart`, `optimized_game_board.dart`, `optimized_game_board_v2.dart`, `widget_based_board.dart` — five different rendering implementations; only `fast_game_board.dart` is used in production. |
| **No state management** | All state lives in `StatefulWidget` local state or `ChangeNotifier` singletons. There is no `Riverpod`, `Bloc`, or `Provider` pattern used consistently — `OgsService` is a `ChangeNotifier` but the game itself is raw widget state. |
| **No persistence** | Completed games are never saved. The history page has no data source. |
| **OGS WebSocket never receives game moves** | `WebSocketService.connect()` authenticates but the game-move event pipeline (`game/<id>/move`, `game/<id>/clock`, etc.) is not implemented — online games would crash or hang. |
| **`dtd_service.dart` unexplained** | A `DtdService` file exists in services with no usage, no documentation, and no tests. |
| **`analysis_options.yaml` empty rules** | No lint rules are configured; code style is unenforced. |

### 1.4 Missing Features (vs. production-quality GO app)

- No AI opponent (Katago, GnuGo, or even a simple random mover)
- No timer / game clock
- No SGF (Smart Game Format) import/export
- No undo confirmation dialog (accidental undo is instant and permanent beyond the in-memory stack)
- No tutorial or on-boarding beyond the `/learn` placeholder
- No persistent game history (database)
- No user profile or ELO/ranking system
- No sound effects or haptic feedback
- No tablet-optimised layout (iPad split view)
- No accessibility labels on interactive elements

---

## Section 2: Recommended Tech Stack for Chess Web App

Given a **6–7 hour coding window** the following stack minimises setup friction while hitting all Level-4 requirements.

| Layer | Choice | Reason |
|---|---|---|
| **Framework** | Next.js 14 (App Router) + TypeScript | File-based routing, RSC for SEO, first-class Vercel support |
| **Styling** | Tailwind CSS + shadcn/ui | Zero custom CSS; accessible primitives already built |
| **Chess logic** | `chess.js` v1 | Battle-tested; handles all rules incl. castling, en passant, stalemate |
| **Board UI** | `react-chessboard` (v4) | Drag-and-drop, arrow annotations, customisable pieces out of the box |
| **Chess AI** | `stockfish.js` (WASM 16) | Runs entirely in browser via Web Worker; no server cost |
| **Auth + DB** | Supabase (free tier) | Postgres + Row-Level Security + OAuth in one dashboard |
| **Realtime** | Supabase Realtime (Broadcast) | WebSocket channel per game room; no extra infra |
| **Payments** | Stripe Checkout (test mode) | Most recognisable payment UI; works with demo keys |
| **Deployment** | Vercel | Zero-config Next.js deployment; instant preview URLs |
| **State** | Zustand | Tiny, no boilerplate; perfect for game state |

### Folder Structure
```
chess-app/
├── app/
│   ├── (auth)/
│   │   ├── login/page.tsx
│   │   └── callback/route.ts
│   ├── game/
│   │   ├── [roomId]/page.tsx      ← multiplayer room
│   │   └── ai/page.tsx            ← vs Stockfish
│   ├── history/page.tsx
│   ├── leaderboard/page.tsx
│   ├── coach/[gameId]/page.tsx    ← post-game analysis
│   ├── upgrade/page.tsx           ← Stripe Checkout
│   └── layout.tsx
├── components/
│   ├── board/
│   │   ├── ChessBoard.tsx
│   │   ├── MoveList.tsx
│   │   └── GameControls.tsx
│   ├── coach/
│   │   ├── AnalysisPanel.tsx
│   │   └── CentipawnGraph.tsx
│   ├── ui/                        ← shadcn/ui components
│   └── layout/
│       ├── Navbar.tsx
│       └── ThemeToggle.tsx
├── lib/
│   ├── supabase/
│   │   ├── client.ts
│   │   └── server.ts
│   ├── stockfish/
│   │   └── worker.ts
│   ├── chess/
│   │   └── utils.ts
│   └── stripe/
│       └── client.ts
├── store/
│   └── gameStore.ts               ← Zustand
├── hooks/
│   ├── useStockfish.ts
│   └── useMultiplayer.ts
└── public/
    └── pieces/                    ← custom skin PNGs
```

---

## Section 3: Step-by-Step Claude Opus Prompts

Each prompt below is **fully self-contained**. Feed them to Claude one at a time in order.

---

### Prompt 1 — Project Scaffold

````
You are an expert Next.js developer. Create a complete project scaffold for a chess web application.

**Tech Stack:**
- Next.js 14 with App Router + TypeScript
- Tailwind CSS + shadcn/ui
- Supabase for auth and database
- Zustand for state management
- chess.js v1 for chess logic
- react-chessboard v4 for the board UI

**Tasks:**

1. Generate the exact shell commands to scaffold the project:
```bash
npx create-next-app@14 chess-app --typescript --tailwind --app --src-dir=false
cd chess-app
npm install chess.js react-chessboard zustand @supabase/supabase-js @supabase/ssr
npx shadcn-ui@latest init
npx shadcn-ui@latest add button card dialog badge toast sheet tabs
```

2. Create `lib/supabase/client.ts` — browser Supabase client using `createBrowserClient` from `@supabase/ssr`.

3. Create `lib/supabase/server.ts` — server-side Supabase client using `createServerClient` from `@supabase/ssr` with Next.js `cookies()`.

4. Create `app/layout.tsx` — root layout with:
   - Inter font
   - Dark/light theme provider (next-themes)
   - A `<Navbar />` component (just the shell; we'll fill it later)
   - Supabase auth session hydration via server component

5. Create `components/layout/Navbar.tsx` — top navigation bar with:
   - Logo: "♟ ChessMaster" on the left
   - Links: Home, Play, Leaderboard, History (hidden when not logged in)
   - Right side: ThemeToggle + "Sign In" button OR user avatar dropdown (Sign Out, Profile)
   - Use shadcn/ui `Button`, `DropdownMenu`

6. Create `components/layout/ThemeToggle.tsx` — icon button switching between light/dark using `next-themes`.

7. Create `app/page.tsx` — landing page hero with:
   - Bold headline: "Play Chess. Improve Daily."
   - Three CTA cards: "Play vs AI", "Play vs Friend", "Watch Demo"
   - Each card uses shadcn `Card` component with an icon, title, and description
   - "Upgrade to Pro" banner at the bottom with a golden gradient background

8. Create `store/gameStore.ts` — Zustand store with this shape:
```ts
interface GameStore {
  fen: string;
  pgn: string;
  orientation: 'white' | 'black';
  gameId: string | null;
  isGameOver: boolean;
  result: string | null;
  setFen: (fen: string) => void;
  setPgn: (pgn: string) => void;
  resetGame: () => void;
}
```

9. Create `.env.local.example` with:
```
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
STRIPE_SECRET_KEY=
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=
STRIPE_WEBHOOK_SECRET=
```

Produce complete, production-ready TypeScript code for every file. No placeholders.
````

---

### Prompt 2 — Chess Board Component

````
You are building a chess web app in Next.js 14 + TypeScript. The chess board page is the core UI.

**Dependencies already installed:** `chess.js`, `react-chessboard`, `zustand`

**Tasks:**

1. Create `components/board/ChessBoard.tsx` — the main interactive board component:
   - Use `Chess` from `chess.js` for game state
   - Use `Chessboard` from `react-chessboard` for rendering
   - Features:
     - Drag-and-drop piece movement
     - Click-to-move (click source, then click destination)
     - Legal move highlighting: when a piece is selected, highlight all valid destination squares with a semi-transparent green dot
     - Last move highlight (yellow tint on source and destination squares)
     - Illegal move snap-back animation (built into react-chessboard)
     - Show promotion dialog when a pawn reaches the back rank (use shadcn Dialog)
   - Props interface:
     ```ts
     interface ChessBoardProps {
       fen?: string;
       orientation?: 'white' | 'black';
       onMove?: (move: { from: string; to: string; promotion?: string }) => void;
       interactive?: boolean; // false = view-only mode for analysis
       lastMove?: { from: string; to: string } | null;
       arrowAnnotations?: Array<{ from: string; to: string; color: string }>;
     }
     ```
   - Use Zustand `gameStore` to sync FEN after every move

2. Create `components/board/MoveList.tsx`:
   - Display moves in algebraic notation in two columns (White | Black)
   - Highlight the current move in blue
   - Clicking a move in the list calls `onJumpToMove(moveIndex)` callback
   - Auto-scrolls to the latest move

3. Create `components/board/GameControls.tsx`:
   - Four icon buttons: ⏮ First, ◀ Previous, ▶ Next, ⏭ Last
   - "Resign" button (red, shown only during active game)
   - "Offer Draw" button
   - "New Game" button
   - Pass all handlers as props

4. Create `app/game/ai/page.tsx` — "Play vs AI" page:
   - Left: `<ChessBoard />` (full height)
   - Right panel: `<MoveList />` + `<GameControls />` + difficulty selector (Easy / Medium / Hard / Master radio group)
   - Show player name and captured pieces above/below the board
   - Handle "Game Over" state: show result banner ("Checkmate! You won 🎉" etc.)
   - The AI integration is NOT implemented yet in this step — just add `// TODO: trigger Stockfish move` comment after each player move

Produce complete TypeScript + Tailwind code. Use shadcn/ui components where possible.
````

---

### Prompt 3 — Game Modes UI & Home Page

````
You are building a chess web app in Next.js 14. Complete the home page and game mode selection.

**Existing files:** `app/page.tsx` (hero landing), `app/game/ai/page.tsx` (skeleton)

**Tasks:**

1. Update `app/page.tsx` — full landing page:
   - Hero section: animated chess board SVG background (CSS keyframes, subtle floating pieces), headline "Play Chess. Improve Daily.", two CTA buttons: "Play Now" (primary) and "Watch Demo" (outline)
   - Features grid (3 columns on desktop, 1 on mobile):
     - 🤖 AI Opponent — "Challenge Stockfish at 4 difficulty levels"
     - 🌐 Multiplayer — "Play with a friend via shareable link"
     - 🧠 AI Coach — "Get post-game analysis and improve faster"
     - 🏆 Leaderboard — "Compete globally, filtered by city"
     - 🎨 Custom Pieces — "Unlock premium piece sets (Pro)"
     - ⚡ Unlimited Games — "Full history and PGN export (Pro)"
   - "How It Works" section: 3 steps with icons and short descriptions
   - Pricing section with two cards:
     - **Free:** Play vs AI (Easy only), 5 game history, standard pieces
     - **Pro ($5/month):** All difficulty levels, unlimited history, 5 piece skins, AI Coach — `<Button>` that links to `/upgrade`
   - Footer: GitHub link, "Built in 6 hours" badge

2. Create `app/game/demo/page.tsx` — "Watch Demo" mode:
   - Auto-plays a famous game (e.g., Kasparov vs Deep Blue 1997, Game 6) move by move
   - 1-second delay between moves (useEffect + setTimeout)
   - Controls: Play/Pause, speed slider (0.5x, 1x, 2x)
   - Narration text below the board for each notable move
   - Non-interactive board (interactive=false on ChessBoard)

3. Create `components/ui/GameModeCard.tsx` — reusable card:
   ```ts
   interface GameModeCardProps {
     icon: React.ReactNode;
     title: string;
     description: string;
     badge?: string; // e.g. "Pro" shown as a golden badge
     onClick: () => void;
     disabled?: boolean;
   }
   ```

4. Create `app/game/friend/page.tsx` — placeholder:
   - Shows a "Create Game Room" button and a text input for "Enter room code"
   - We'll implement the real logic in Prompt 6 (Multiplayer)
   - For now just show the UI shell

Produce complete TypeScript + Tailwind code. Ensure mobile responsiveness.
````

---

### Prompt 4 — Stockfish AI Integration

````
You are building a chess web app in Next.js 14 + TypeScript. Integrate Stockfish.js WASM for AI gameplay.

**Dependencies:** `chess.js` (already installed). Stockfish WASM must be loaded from CDN or npm.

Install command: `npm install stockfish`

**Tasks:**

1. Create `lib/stockfish/worker.ts` — Stockfish Web Worker wrapper:
   - Load Stockfish WASM via `new Worker('/stockfish.js')` (place the stockfish.js WASM file in `/public/`)
   - Alternatively use the npm `stockfish` package: `import Stockfish from 'stockfish'`
   - Implement a Promise-based API:
     ```ts
     class StockfishEngine {
       private worker: Worker;
       private messageQueue: Map<string, (value: string) => void>;
       
       async init(): Promise<void>
       async getBestMove(fen: string, depth: number): Promise<string>
       async getAnalysis(fen: string, depth: number): Promise<AnalysisResult>
       destroy(): void
     }
     
     interface AnalysisResult {
       bestMove: string;
       score: number; // centipawns
       depth: number;
       pv: string[]; // principal variation (sequence of best moves)
       mate: number | null; // moves to mate, if applicable
     }
     ```
   - `getBestMove` sends `position fen <fen>` then `go depth <depth>` and resolves when `bestmove` line is received
   - Difficulty → depth mapping: Easy=5, Medium=10, Hard=15, Master=20

2. Create `hooks/useStockfish.ts` — React hook:
   ```ts
   function useStockfish(difficulty: 'easy' | 'medium' | 'hard' | 'master') {
     // Returns:
     // { getMove: (fen: string) => Promise<string>, isThinking: boolean, destroy: () => void }
   }
   ```
   - Initializes engine once on mount, destroys on unmount
   - Sets `isThinking` to true while waiting for move
   - Handles errors gracefully (shows toast on failure)

3. Update `app/game/ai/page.tsx`:
   - Import and use `useStockfish(difficulty)`
   - After each player move:
     1. Update FEN in game state
     2. Check if game is over (`chess.isGameOver()`) — if so, show result
     3. If not over and it's the AI's turn: call `getMove(fen)`, then apply the returned move to the chess instance
     4. Show a "thinking" spinner with "Stockfish is thinking..." during AI calculation
   - Difficulty selector: `<RadioGroup>` with Easy / Medium / Hard / Master — changing difficulty re-initializes the engine at new depth
   - Add a "Hint" button (Pro feature): shows the best move arrow on the board for 2 seconds (use `arrowAnnotations` prop on ChessBoard)

4. Create `public/stockfish.js` — add instructions comment:
   - Copy `stockfish.js` and `stockfish.wasm` from `node_modules/stockfish/` to `public/`
   - Add a `next.config.js` rule to allow the WASM MIME type:
     ```js
     // next.config.js
     module.exports = {
       async headers() {
         return [{ source: '/stockfish.wasm', headers: [{ key: 'Content-Type', value: 'application/wasm' }] }];
       },
     };
     ```

Produce complete TypeScript code. Handle edge cases: promotion moves (append promotion piece to UCI string), side to move detection, and engine timeout (reject after 10 seconds).
````

---

### Prompt 5 — Supabase Auth + Game History

````
You are building a chess web app in Next.js 14 + TypeScript with Supabase.

**Supabase project is already created. Client files exist at `lib/supabase/client.ts` and `lib/supabase/server.ts`.**

**Tasks:**

1. Run this SQL in the Supabase dashboard SQL editor — create all required tables:
```sql
-- Profiles (extends auth.users)
create table public.profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  username text unique not null,
  avatar_url text,
  city text,
  country text,
  elo integer default 1200,
  is_pro boolean default false,
  created_at timestamptz default now()
);

-- Games
create table public.games (
  id uuid primary key default gen_random_uuid(),
  white_id uuid references public.profiles(id),
  black_id uuid references public.profiles(id),
  pgn text not null,
  result text, -- '1-0', '0-1', '1/2-1/2'
  time_control text,
  game_mode text, -- 'ai', 'friend', 'demo'
  ai_difficulty text,
  elo_change_white integer,
  elo_change_black integer,
  created_at timestamptz default now()
);

-- RLS Policies
alter table public.profiles enable row level security;
alter table public.games enable row level security;

create policy "Public profiles are viewable by everyone"
  on public.profiles for select using (true);

create policy "Users can update own profile"
  on public.profiles for update using (auth.uid() = id);

create policy "Users can view own games"
  on public.games for select using (
    auth.uid() = white_id or auth.uid() = black_id
  );

create policy "Users can insert own games"
  on public.games for insert with check (
    auth.uid() = white_id or auth.uid() = black_id
  );
```

2. Create `app/(auth)/login/page.tsx`:
   - Email + password sign-in form using shadcn `Form`, `Input`, `Button`
   - "Continue with Google" OAuth button
   - "Continue with GitHub" OAuth button
   - Toggle between "Sign In" and "Sign Up" modes
   - On sign-up, ask for `username` and `city` (saved to profiles table)
   - Show loading state and error messages inline

3. Create `app/(auth)/callback/route.ts` — OAuth callback handler using Supabase SSR.

4. Create `lib/supabase/actions.ts` — server actions:
   ```ts
   export async function saveGame(pgn: string, result: string, gameMode: string, difficulty?: string): Promise<string>
   export async function getGameHistory(userId: string, page: number): Promise<Game[]>
   export async function getUserProfile(userId: string): Promise<Profile>
   export async function updateElo(winnerId: string, loserId: string): Promise<void>
   ```

5. Create `app/history/page.tsx`:
   - Server component that fetches last 20 games for the current user
   - Table columns: Date, Opponent, Result (green W / red L / grey D), Moves, ELO change, "View Analysis" link
   - Pagination (10 games per page)
   - "Export PGN" button for each game (downloads .pgn file)
   - Empty state: "No games yet — play your first game!"
   - Pro gate: free users see only 5 games; 6th row shows a blurred locked overlay with "Upgrade to Pro"

6. Update `app/game/ai/page.tsx`:
   - After game ends, call `saveGame(pgn, result, 'ai', difficulty)`
   - Show "View Analysis" button that links to `/coach/[gameId]`

Produce complete TypeScript code for all files.
````

---

### Prompt 6 — Multiplayer via Supabase Realtime

````
You are building a chess web app in Next.js 14 + TypeScript with Supabase Realtime for multiplayer.

**Supabase client is set up. The `games` table already exists.**

**How it works:**
1. Player A clicks "Play with Friend" → creates a room → gets a shareable link `/game/[roomId]`
2. Player B opens the link → joins as the opponent
3. Moves are synced via Supabase Realtime Broadcast channel `room:<roomId>`
4. Spectators can also open the link and watch in read-only mode

**Tasks:**

1. Add a `rooms` table (run in Supabase SQL editor):
```sql
create table public.rooms (
  id uuid primary key default gen_random_uuid(),
  host_id uuid references public.profiles(id),
  guest_id uuid references public.profiles(id),
  fen text default 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
  status text default 'waiting', -- 'waiting', 'active', 'finished'
  created_at timestamptz default now()
);

alter table public.rooms enable row level security;
create policy "Anyone can read rooms" on public.rooms for select using (true);
create policy "Authenticated users can create rooms"
  on public.rooms for insert with check (auth.uid() = host_id);
create policy "Guest can update room"
  on public.rooms for update using (
    auth.uid() = host_id or auth.uid() = guest_id or guest_id is null
  );
```

2. Create `hooks/useMultiplayer.ts`:
```ts
function useMultiplayer(roomId: string, userId: string | null) {
  // Returns:
  // {
  //   fen: string,
  //   orientation: 'white' | 'black',
  //   isMyTurn: boolean,
  //   opponentName: string | null,
  //   status: 'waiting' | 'active' | 'finished',
  //   sendMove: (from: string, to: string, promotion?: string) => void,
  //   isSpectator: boolean,
  // }
}
```
- On mount: subscribe to Supabase Realtime channel `room:${roomId}`
- Listen for `MOVE` broadcast events: update local chess instance with the incoming move
- `sendMove` broadcasts `{ type: 'MOVE', from, to, promotion }` to the channel AND updates the `rooms.fen` in the database
- Handle opponent disconnect: show "Opponent disconnected" toast with "Claim Victory" and "Wait" options

3. Update `app/game/friend/page.tsx` — full implementation:
   - "Create Room" button: calls Supabase insert on `rooms`, redirects to `/game/[roomId]`
   - "Join Room" form: input for room code → redirects to `/game/[roomId]`

4. Create `app/game/[roomId]/page.tsx`:
   - Server component: fetch room from Supabase
   - Determine if current user is host, guest, or spectator
   - Render `<MultiplayerGame roomId={roomId} />` client component

5. Create `components/board/MultiplayerGame.tsx`:
   - Uses `useMultiplayer` hook
   - If `status === 'waiting'`: show "Waiting for opponent..." with the shareable link and a copy button
   - If `status === 'active'`: render `<ChessBoard interactive={isMyTurn} />` + `<MoveList />` + `<GameControls />`
   - If `isSpectator`: render view-only board with both players' names
   - On game over: save game to `games` table, update ELO, show result modal

Produce complete TypeScript code for all files.
````

---

### Prompt 7 — AI Coach Feature

````
You are building a chess web app in Next.js 14. Implement the "AI Coach" post-game analysis feature using Stockfish.js WASM.

**Existing:** `lib/stockfish/worker.ts` (StockfishEngine class), `app/history/page.tsx` (game history), Supabase `games` table.

**How AI Coach works:**
1. User finishes a game or clicks "View Analysis" from history
2. App loads the PGN, replays all moves, and at each position asks Stockfish (depth 18) for the evaluation and best move
3. Each move is classified: Brilliant (■■), Best (■), Excellent (!), Good, Inaccuracy (?), Mistake (??), Blunder (?!?)
4. Results displayed as: coloured move list, centipawn graph, "Coach says" text per move

**Classification thresholds (centipawn loss):**
- Brilliant: engine wasn't expecting it but it's the best move
- Best: = top engine move, eval loss 0
- Excellent: eval loss 0–10 cp
- Good: 10–30 cp loss
- Inaccuracy: 30–100 cp loss
- Mistake: 100–200 cp loss
- Blunder: >200 cp loss or allows checkmate

**Tasks:**

1. Update `lib/stockfish/worker.ts` — add `analyzeGame(pgn: string)` method:
   - Parse PGN with `chess.js`
   - For each position: call `getAnalysis(fen, 18)` 
   - Yield results progressively (use `AsyncGenerator<MoveAnalysis>`)
   - ```ts
     interface MoveAnalysis {
       moveNumber: number;
       move: string;        // SAN notation
       fen: string;
       score: number;       // centipawns (positive = white advantage)
       bestMove: string;    // what engine recommends instead
       classification: 'brilliant' | 'best' | 'excellent' | 'good' | 'inaccuracy' | 'mistake' | 'blunder';
       explanation: string; // e.g. "Better was Nf3, maintaining the pin"
     }
     ```

2. Create `hooks/useGameAnalysis.ts`:
   - Takes a `pgn: string`
   - Returns `{ analyses: MoveAnalysis[], progress: number, isAnalyzing: boolean }`
   - Runs analysis asynchronously, updating state as each move is classified
   - `progress` = 0–100 (percentage of moves analysed)

3. Create `app/coach/[gameId]/page.tsx`:
   - Server component: fetch game PGN from Supabase
   - Pro gate: if user is not Pro, show upgrade prompt with blurred analysis preview
   - Render `<AnalysisPage pgn={pgn} />` client component

4. Create `components/coach/AnalysisPage.tsx`:
   - Left: `<ChessBoard interactive={false} fen={currentFen} arrowAnnotations={[bestMoveArrow]} />`
   - Right panel:
     - Analysis progress bar (during loading)
     - `<CentipawnGraph />`
     - `<AnnotatedMoveList moves={analyses} onSelect={setCurrentMove} />`
   - Below board: "Coach says" panel — show `explanation` for selected move in a speech-bubble style card
   - Summary stats at top: Brilliant: N, Best: N, Blunders: N, Accuracy: N% (for both players)

5. Create `components/coach/CentipawnGraph.tsx`:
   - SVG area chart showing evaluation over time (x = move number, y = centipawns)
   - White advantage = area above 0 (white fill), black advantage = area below 0 (black fill)
   - Click on a point in the graph to jump to that move
   - Clamp y-axis at ±800 cp (beyond that it's effectively won/lost)
   - Show a vertical cursor line at the current move

6. Create `components/coach/AnnotatedMoveList.tsx`:
   - Shows moves with coloured classification badges
   - Colour scheme: Brilliant=cyan, Best=green, Excellent=teal, Good=grey, Inaccuracy=yellow, Mistake=orange, Blunder=red

Produce complete TypeScript + Tailwind code. The analysis must run without blocking the UI thread.
````

---

### Prompt 8 — Global Leaderboard with ELO & City Filter

````
You are building a chess web app in Next.js 14 + TypeScript + Supabase. Implement the global leaderboard.

**Existing tables:** `profiles` (has `elo`, `city`, `country`), `games` (has results and ELO changes)

**Tasks:**

1. Add SQL view and indexes (run in Supabase):
```sql
-- Fast leaderboard query
create index if not exists idx_profiles_elo on public.profiles(elo desc);
create index if not exists idx_profiles_city on public.profiles(city);

-- Leaderboard view
create or replace view public.leaderboard as
select
  p.id,
  p.username,
  p.avatar_url,
  p.city,
  p.country,
  p.elo,
  count(g.id) filter (where g.white_id = p.id or g.black_id = p.id) as total_games,
  count(g.id) filter (
    where (g.white_id = p.id and g.result = '1-0')
       or (g.black_id = p.id and g.result = '0-1')
  ) as wins,
  round(
    count(g.id) filter (
      where (g.white_id = p.id and g.result = '1-0')
         or (g.black_id = p.id and g.result = '0-1')
    )::numeric /
    nullif(count(g.id) filter (where g.white_id = p.id or g.black_id = p.id), 0) * 100
  , 1) as win_rate
from public.profiles p
left join public.games g on g.white_id = p.id or g.black_id = p.id
group by p.id;
```

2. Create `app/leaderboard/page.tsx` — server component:
   - Fetch top 100 players from the `leaderboard` view
   - Pass data to `<LeaderboardClient />` client component for filtering

3. Create `components/leaderboard/LeaderboardClient.tsx`:
   - Top bar: search input, city dropdown filter, country flag emoji, "Global / My City" toggle
   - Table columns: Rank, Avatar+Username, City/Country, ELO, Games, Wins, Win%, Actions ("Challenge" button)
   - Current user's row is highlighted
   - Rank 1–3 show 🥇🥈🥉 instead of numbers
   - ELO change from last game shown as `+12` (green) or `-8` (red) next to the ELO number
   - "Challenge" button: creates a new multiplayer room and shows "Send Link" modal

4. Create `components/leaderboard/EloRatingBadge.tsx`:
   - Displays ELO with a coloured tier badge:
     - < 1000: 🟤 Beginner
     - 1000–1199: 🟢 Intermediate
     - 1200–1399: 🔵 Advanced
     - 1400–1599: 🟣 Expert
     - 1600–1799: 🟠 Master
     - 1800+: 🔴 Grandmaster

5. Create `app/profile/[username]/page.tsx`:
   - Server component: fetch profile + recent games
   - Profile card: avatar, username, city, ELO badge, "Since" date
   - Win/Loss/Draw pie chart (using an SVG donut chart, no external chart library)
   - Recent games list (last 10)
   - "Challenge to a game" button (creates multiplayer room)

6. Update ELO calculation in `lib/supabase/actions.ts` — `updateElo()`:
   - Use standard Elo formula: `K=32` for <2100 rated, `K=24` for 2100–2400, `K=16` for 2400+
   - Expected score: `E = 1 / (1 + 10^((opponentElo - playerElo) / 400))`
   - New ELO: `newElo = oldElo + K * (actualScore - expectedScore)`

Produce complete TypeScript code for all files.
````

---

### Prompt 9 — Monetization Layer (Stripe + Pro Tier)

````
You are building a chess web app in Next.js 14 + TypeScript. Implement the monetization and Pro tier.

**Existing:** Supabase `profiles.is_pro` column, `STRIPE_SECRET_KEY` and `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY` in `.env.local`.

**Important:** Use Stripe in TEST MODE only. Use test card `4242 4242 4242 4242`.

Install: `npm install stripe @stripe/stripe-js`

**Free vs Pro tier:**
| Feature | Free | Pro ($5/month) |
|---------|------|----------------|
| Play vs AI | Easy only | All difficulties |
| Game history | 5 games | Unlimited |
| AI Coach | ❌ | ✅ |
| Piece skins | Standard only | 5 custom sets |
| Hints | ❌ | ✅ (3/game) |
| Leaderboard | View only | Full profile |

**Tasks:**

1. Create Stripe product and price (instructions, not code):
   - Go to stripe.com/dashboard (test mode)
   - Create Product: "ChessMaster Pro", Price: $5.00/month recurring
   - Copy the Price ID (starts with `price_`) → save as `STRIPE_PRICE_ID` in `.env.local`

2. Create `app/api/stripe/checkout/route.ts` — POST endpoint:
   - Creates a Stripe Checkout Session with `mode: 'subscription'`
   - `success_url`: `/upgrade/success?session_id={CHECKOUT_SESSION_ID}`
   - `cancel_url`: `/upgrade`
   - Attaches Supabase `userId` as `client_reference_id`
   - Returns `{ url: string }` to redirect client

3. Create `app/api/stripe/webhook/route.ts` — webhook handler:
   - Verify Stripe signature using `STRIPE_WEBHOOK_SECRET`
   - On `checkout.session.completed`: set `profiles.is_pro = true` for the user
   - On `customer.subscription.deleted`: set `profiles.is_pro = false`
   - Use Supabase service role client (bypasses RLS)

4. Create `app/upgrade/page.tsx`:
   - Two pricing cards side by side (Free vs Pro)
   - Pro card has a golden border and "Most Popular" badge
   - "Upgrade Now — $5/month" button calls the `/api/stripe/checkout` endpoint and redirects to Stripe
   - "Test card: 4242 4242 4242 4242" shown discreetly below the button for demo purposes
   - Bullet list of Pro features with checkmarks

5. Create `app/upgrade/success/page.tsx`:
   - "You're now a Pro member! 🎉" confirmation
   - Shows confetti animation (CSS keyframes, no library)
   - Button: "Start Playing" → `/game/ai`

6. Create `components/ui/ProGate.tsx` — wrapper component:
   ```ts
   interface ProGateProps {
     isPro: boolean;
     feature: string; // e.g. "AI Coach", "Hard difficulty"
     children: React.ReactNode;
   }
   ```
   - If `isPro`: render children
   - If not Pro: render children with a semi-transparent overlay + lock icon + "Upgrade to Pro" button
   - The overlay is `pointer-events: none` on children so users can see but not interact

7. Create `components/pieces/PieceSkinSelector.tsx`:
   - Grid of 6 piece set previews (standard + 5 premium)
   - Premium sets show a lock overlay for free users
   - On select, updates `localStorage` with chosen skin name
   - Piece set names: `standard`, `neo`, `wood`, `glass`, `neon`, `metal`
   - Images: use placeholder SVGs or simple colored shapes for demo

8. Create `components/ui/UpgradeModal.tsx`:
   - Modal triggered when a free user tries to access a Pro feature
   - Shows what feature they tried to access, lists all Pro benefits
   - "Upgrade Now" CTA and "Maybe Later" dismiss

Apply `ProGate` wrapper in:
- `app/game/ai/page.tsx`: difficulty selector (wrap Medium/Hard/Master options)
- `app/coach/[gameId]/page.tsx`: entire analysis content
- `app/history/page.tsx`: games 6+ in the list

Produce complete TypeScript code for all files.
````

---

### Prompt 10 — Polish, Dark/Light Theme & Deployment

````
You are finalising a chess web app in Next.js 14 + TypeScript. Add theme support, mobile responsiveness fixes, SEO, and deploy to Vercel.

**Tasks:**

1. Install `next-themes`: `npm install next-themes`

2. Create `components/providers/ThemeProvider.tsx`:
   - Wraps `{ ThemeProvider }` from `next-themes`
   - `attribute="class"`, `defaultTheme="system"`, `enableSystem`

3. Update `app/layout.tsx`:
   - Wrap content with `<ThemeProvider>`
   - Add dark mode Tailwind config: ensure `tailwind.config.ts` has `darkMode: 'class'`

4. Update `components/layout/ThemeToggle.tsx`:
   - Use `useTheme()` from `next-themes`
   - Animated sun/moon icon transition

5. Update ALL pages and components to use dark mode variants:
   - Backgrounds: `bg-white dark:bg-gray-900`
   - Cards: `bg-gray-50 dark:bg-gray-800`
   - Text: `text-gray-900 dark:text-gray-100`
   - Borders: `border-gray-200 dark:border-gray-700`

6. Mobile responsiveness audit — fix these specific issues:
   - `app/game/ai/page.tsx`: on mobile (<768px), move list goes BELOW the board, not beside it. Use `flex-col md:flex-row`.
   - `app/leaderboard/page.tsx`: table scrolls horizontally on mobile. Wrap table in `overflow-x-auto`.
   - `app/coach/[gameId]/page.tsx`: centipawn graph shrinks to `h-24` on mobile.
   - Navbar: hamburger menu on mobile using shadcn `Sheet`.

7. Add SEO metadata in `app/layout.tsx`:
```ts
export const metadata: Metadata = {
  title: 'ChessMaster — Play, Learn, Improve',
  description: 'A modern chess platform with AI opponent, multiplayer, AI coach, and global leaderboard.',
  keywords: ['chess', 'chess game', 'play chess online', 'chess AI', 'stockfish'],
  openGraph: {
    title: 'ChessMaster',
    description: 'Play chess with AI, challenge friends, and improve with AI coaching.',
    url: 'https://your-app.vercel.app',
    type: 'website',
  },
};
```

8. Create `next.config.js` (final version):
```js
/** @type {import('next').NextConfig} */
const nextConfig = {
  async headers() {
    return [
      {
        source: '/stockfish.wasm',
        headers: [
          { key: 'Content-Type', value: 'application/wasm' },
          { key: 'Cross-Origin-Embedder-Policy', value: 'require-corp' },
          { key: 'Cross-Origin-Opener-Policy', value: 'same-origin' },
        ],
      },
    ];
  },
  images: {
    remotePatterns: [{ hostname: '*.supabase.co' }],
  },
};

module.exports = nextConfig;
```

9. Create `README.md`:
```markdown
# ♟ ChessMaster

> A modern chess platform built for a hackathon in ~6 hours.

## What it does
- 🤖 Play vs AI powered by Stockfish WASM (Easy/Medium/Hard/Master)
- 🌐 Multiplayer with a friend via shareable link (Supabase Realtime)
- 🧠 AI Coach: post-game move analysis with centipawn graph
- 🏆 Global leaderboard filtered by city, with ELO rating system
- 💰 Stripe-powered Pro tier with custom piece skins

## For whom
Chess players who want a modern, fast, coach-enabled platform — not just a game.

## Why it's valuable
Most chess sites are feature-heavy and slow. This app is laser-focused on improvement:
play → analyse → improve. The AI Coach is the key differentiator.

## Tech stack
Next.js 14 · TypeScript · Tailwind · shadcn/ui · chess.js · Stockfish WASM ·
Supabase (Auth + DB + Realtime) · Stripe · Vercel

## Setup
1. Clone the repo
2. Copy `.env.local.example` to `.env.local` and fill in keys
3. Run the SQL from `supabase/schema.sql`
4. `npm install && npm run dev`

## Demo
Live: https://chess-master.vercel.app
Test Stripe card: `4242 4242 4242 4242`, any future date, any CVC
```

10. Vercel deployment:
    - Push to GitHub
    - Import project on vercel.com
    - Add all env variables from `.env.local`
    - Set `NEXT_PUBLIC_SITE_URL` to the Vercel preview URL
    - Add the Vercel URL to Supabase → Authentication → Redirect URLs

Produce complete TypeScript code for all changed files. At the end, list all env variables needed.
````

---

## Section 4: Time Budget

Total available: **6.5 hours** (390 minutes)

| Step | Prompt | Estimated Time | Priority | Can Cut? |
|------|--------|---------------|----------|----------|
| 1 | Project Scaffold | 25 min | 🔴 Critical | No |
| 2 | Chess Board Component | 40 min | 🔴 Critical | No |
| 3 | Game Modes UI | 30 min | 🟡 High | Simplify demo page |
| 4 | Stockfish AI | 35 min | 🔴 Critical | Reduce to 2 difficulties |
| 5 | Auth + Game History | 40 min | 🟡 High | Skip ELO on first pass |
| 6 | Multiplayer | 50 min | 🟡 High | Skip spectator mode |
| 7 | AI Coach | 45 min | 🟠 Medium | Skip graph, do text-only |
| 8 | Leaderboard | 35 min | 🟠 Medium | Skip profile pages |
| 9 | Monetization | 30 min | 🟡 High | Skip webhook, just show UI |
| 10 | Polish + Deploy | 30 min | 🔴 Critical | Skip dark mode details |
| **Buffer** | Debugging | 30 min | — | — |
| **Total** | | **390 min** | | |

### If Running Short on Time — Cut in This Order:

1. **Cut first:** Demo game replay page (Prompt 3 → just show landing page)
2. **Cut second:** Centipawn graph (Prompt 7 → text analysis only)
3. **Cut third:** Spectator mode in multiplayer (Prompt 6 → host + guest only)
4. **Cut fourth:** Profile pages (Prompt 8 → leaderboard table only)
5. **Cut fifth:** Stripe webhook (Prompt 9 → show upgrade UI but don't activate Pro automatically)

### Must Ship (Minimum Viable "Level Great"):
- Working chess board with legal moves ✅
- Stockfish AI at 2+ difficulties ✅
- Supabase Auth + game history ✅
- Multiplayer via link (at least create + join) ✅
- "Upgrade to Pro" button visible ✅
- Deployed on Vercel ✅

---

## Section 5: Monetization Demo Blueprint

### Tier Definitions

#### Free Tier
| Feature | Limit |
|---------|-------|
| Play vs AI | Easy difficulty only |
| Game history | 5 games |
| AI Coach | ❌ Locked |
| Piece skins | Standard only |
| Hints | ❌ Locked |
| Leaderboard | View only (no profile) |

#### Pro Tier — $5/month
| Feature | Limit |
|---------|-------|
| Play vs AI | Easy / Medium / Hard / Master |
| Game history | Unlimited + PGN export |
| AI Coach | ✅ Full post-game analysis |
| Piece skins | 5 premium sets |
| Hints | 3 per game |
| Leaderboard | Full profile + city ranking |

### Stripe Test Mode Setup

1. Sign up at [stripe.com](https://stripe.com) (no credit card needed for test mode)
2. Switch to **Test mode** (toggle in dashboard top bar)
3. Create a Product:
   - Name: `ChessMaster Pro`
   - Pricing: Recurring, `$5.00 / month`
   - Copy the `price_XXXXXXXXXX` ID
4. Go to **Developers → Webhooks** → Add endpoint:
   - URL: `https://your-vercel-url.vercel.app/api/stripe/webhook`
   - Events to listen: `checkout.session.completed`, `customer.subscription.deleted`
   - Copy the webhook signing secret (`whsec_...`)
5. Add to `.env.local`:
   ```
   STRIPE_SECRET_KEY=sk_test_...
   NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...
   STRIPE_PRICE_ID=price_...
   STRIPE_WEBHOOK_SECRET=whsec_...
   ```

### Test Card Numbers (Stripe Test Mode)
| Scenario | Card Number |
|----------|-------------|
| Successful payment | `4242 4242 4242 4242` |
| Declined | `4000 0000 0000 0002` |
| 3D Secure required | `4000 0025 0000 3155` |

All expiry dates in the future, any 3-digit CVC, any 5-digit ZIP.

### Showing "Locked" UI for Free Users

The `ProGate` component (Prompt 9, Task 6) handles this pattern:

```tsx
// Usage — wrap any Pro-only feature:
<ProGate isPro={user?.is_pro ?? false} feature="AI Coach">
  <AnalysisPage pgn={pgn} />
</ProGate>
```

The overlay renders as:
```tsx
// Inside ProGate when isPro === false:
<div className="relative">
  {/* Blurred, non-interactive preview */}
  <div className="pointer-events-none select-none blur-sm opacity-50">
    {children}
  </div>
  {/* Lock overlay */}
  <div className="absolute inset-0 flex flex-col items-center justify-center bg-white/80 dark:bg-gray-900/80 rounded-xl">
    <LockIcon className="w-12 h-12 text-gray-400 mb-4" />
    <h3 className="text-lg font-semibold mb-2">Pro Feature</h3>
    <p className="text-sm text-gray-500 mb-4">{feature} requires a Pro account</p>
    <Button onClick={() => router.push('/upgrade')} className="bg-amber-500 hover:bg-amber-600">
      Upgrade to Pro — $5/month
    </Button>
  </div>
</div>
```

### Demo Walkthrough Script (for presentation)
1. Open the app → show hero landing page with "Play vs AI" CTA
2. Click Play vs AI → select Easy → play 3 moves → show the board UI
3. Try to select "Hard" difficulty → `ProGate` triggers → "Upgrade to Pro" modal appears
4. Navigate to `/upgrade` → show pricing cards → click "Upgrade Now"
5. Stripe Checkout opens (test mode banner visible) → use `4242 4242 4242 4242`
6. Success page + confetti → now `is_pro = true` in Supabase
7. Return to AI game → Hard difficulty now unlocked
8. Finish the game → show `/coach/[gameId]` analysis with centipawn graph
9. Navigate to `/leaderboard` → filter by city → show ELO rankings
10. Click "Play with Friend" → copy link → open in incognito → both boards sync

This demonstrates the full monetization loop in under 5 minutes.
