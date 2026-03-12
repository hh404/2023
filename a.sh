for iface in en0 en1; do
  ip=$(ipconfig getifaddr $iface 2>/dev/null)
  if [[ -n "$ip" ]]; then
    echo "$ip"
    exit 0
  fi
done

echo "No IP found"