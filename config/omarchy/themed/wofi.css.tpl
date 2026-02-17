window {
  background-color: {{ background }};
  color: {{ foreground }};
  border: 2px solid {{ accent }};
}

#input {
  margin: 8px;
  padding: 8px;
  color: {{ foreground }};
  background-color: {{ color0 }};
  border: 1px solid {{ accent }};
}

#outer-box {
  margin: 6px;
}

#entry {
  padding: 7px 10px;
  border-radius: 4px;
}

#entry:selected {
  background-color: {{ accent }};
  color: {{ background }};
}

#text {
  color: {{ foreground }};
}
