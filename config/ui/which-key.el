;;; which-key.el --- Comprehensive which-key definitions

;; ============================================================================
;; Which-key Configuration - Show available keybindings
;; ============================================================================

(which-key-add-key-based-replacements
  "C-c a" "📅 Org Agenda"
  "C-c b" "📋 Consult Buffer"
  "C-c c" "✏️ Org Capture"
  "C-c d" "📝 Denote"
  ;; C-c f f is a non-prefix key, so C-c f cannot be a prefix
  ;; "C-c f" "🔍 Consult Find"
  "C-c l" "🔗 Store Link"
  "C-c z" "🔍 Xeft Search"
  "C-c M-e" "🦙 Ellama (Ollama)"
  
  ;; Helpful key bindings
  "C-h f" "❓ Helpful Function"
  "C-h x" "❓ Helpful Command"
  "C-h k" "❓ Helpful Key"
  "C-h v" "❓ Helpful Variable"
  
  ;; Helm
  "C-c M-h" "⚙️ Helm Command Prefix"
  
  ;; Fontaine
  "C-c M-f" "🔤 Font Presets"
  "C-c M-f r" "🔤 Regular Font"
  "C-c M-f o" "🔤 Org Reading Font"
  "C-c M-f w" "🔤 Writing Font"
  "C-c M-f p" "🔤 Presentation Font"
  "C-c M-f c" "🔤 Compact Font"
  "C-c M-f l" "🔤 Large Font"
  "C-c M-f t" "🔤 Toggle Font"
  
  ;; Development
  "C-c p" "📁 Project"
  "C-c p f" "📄 Find File"
  "C-c p d" "📁 Find Directory"
  "C-c p g" "🔍 Find Regexp"
  "C-c p s" "🔄 Switch Project"
  "C-c f f" "✨ Format Buffer"
  "C-x g" "🌿 Magit Status"
  "C-x r" "🔖 Bookmarks"
  "C-x r d" "🗑️ Delete Bookmark"
  "C-x u" "↶ Undo Tree"
  "C-x v" "🌿 Version Control"
  "C-x v t" "⏰ Git Timemachine"
  "C-x v p" "💬 Git Messenger"
  
  ;; Themes
  "C-c t" "🎨 Themes"
  "C-c t t" "🔄 Toggle Theme"
  "C-c t d" "🏠 Default Theme"
  "C-c t g" "🖥️ GUI Theme"
  "C-c t SPC" "⚡ Toggle Default/Custom"
  "C-c t r" "🔄 Reset All Themes"
  "C-c t f" "🔧 Fix Theme Issues"
  
  ;; Writing
  "C-c w s d" "📚 Dictionary Lookup"
  "M-$" "✏️ Correct Word"
  "C-M-$" "🌐 Change Language"
  
  ;; Email
  "C-c m b" "👥 BBDB"
  
  ;; Org Extensions
  "C-c n" "📝 Org denote"
  "C-c n h" "📊 Habit Stats"
  "C-c n u" "🔗 Cliplink"
  "C-c n p" "⏰ Pomodoro"
  
  ;; Org GTD
  "C-c g" "✅ GTD"
  "C-c g c" "✏️ GTD Capture (Quick)"
  "C-c g p" "📥 Process Inbox"
  "C-c g e" "🎯 Engage"
  "C-c g n" "⏭️ Next Actions"
  "C-c g s" "🔄 Switch Clarify"
  "C-c g a" "📅 Clarify Agenda"
  "C-c g i" "📝 Clarify Item"
  "C-c g g" "🎯 Engage by Context"
  
  ;; Org Journal
  "C-c j" "📖 Journal"
  "C-c j j" "📝 New Entry"
  "C-c j s" "🔍 Search"
  "C-c j d" "📝 Denote Journal"
  
  ;; Xeft Search
  "C-c z f" "🔍 Xeft Search"
  "C-c z n" "📝 New Note"
  "C-c z s" "🔍 Search Notes"
  "C-c z w" "🔍 Search Word"
  
  ;; Org QL
  "C-c q" "🔍 Org QL"
  "C-c q q" "🔍 Search"
  "C-c q s" "🌳 Sparse Tree"
  "C-c q b" "📄 Search Buffer"
  "C-c q t" "🏷️ Search Tags"
  "C-c q p" "📁 Projects"
  "C-c q d" "📅 Due Today"
  "C-c q w" "📅 Due This Week"
  "C-c q n" "⏭️ Next Actions"
  "C-c q a" "📅 QL Agenda"
  "C-c q i" "📝 Insert Src Block"
  "C-c q I" "📝 Insert at Point"
  "C-c q D" "📝 Insert with Details"
  "C-c q e" "▶️ Execute Src Block"
  "C-c q E" "▶️ Execute Detailed"
  
  ;; Org Web Tools
  "C-c w w" "🌐 Web Link"
  
  ;; Denote
  "C-c d F" "⚡ Fleeting Note"
  "C-c d v" "🎬 Movie Note"
  "C-c d s" "📚 Denote Sequence"
  "C-c d s n" "➕ Create Sequence"
  "C-c d s l" "📋 List Sequences"
  "C-c d s f" "🔍 Find Sequence"
  "C-c d s r" "✏️ Rename Sequence"
  "C-c d s d" "🗑️ Delete Sequence"
  "C-c d s i" "🔗 Insert Link"
  "C-c d s t" "🏷️ Tag Sequence"
  "C-c d s a" "➕ Add to Sequence"
  "C-c d s w" "📅 Weekly Sequence"
  "C-c d s m" "📅 Monthly Sequence"
  
  ;; Org Export
  "C-c e" "📤 Export"
  "C-c e h" "🌐 Export HTML"
  "C-c e m" "📝 Export Markdown"
  "C-c e e" "📋 Export Dispatch"
  
  ;; Dired
  "h" "⬆️ Up Directory"
  "l" "📁 Open File"
  "C-c d C" "📝 Convert to Journal"
  "C-c d s" "✍️ Add Signature"
  "C-c d k" "🏷️ Add Keywords"
  "C-c d d" "📁 Move to Subdir"
  "C-c d r" "✏️ Rename with Date"
  "C-c d R" "✏️ Rename Slugified"
  "C-c d l" "🔗 Relationships"
  "C-c d l c" "👶 Add Child"
  "C-c d l p" "👨 Add Parent"
  "C-c d l s" "👫 Add Siblings"
  "C-c d l r" "🔗 Add Relationship"
  
  ;; Org Mode specific
  "C-c n s" "📸 Screenshot"
  "C-c n y" "🖼️ Paste Image"
  "C-c n t" "🔗 Add Transclusion"
  "C-c n T" "🔄 Toggle Transclusion"
  
  ;; Markdown
  "g" "👁️ Grip Preview")

(provide 'which-key)