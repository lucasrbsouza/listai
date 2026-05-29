-- Create shopping_lists table
CREATE TABLE IF NOT EXISTS shopping_lists (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name text NOT NULL,
  market_name text,
  budget_goal_cents integer,
  is_completed boolean DEFAULT false NOT NULL,
  is_template boolean DEFAULT false NOT NULL,
  completed_at timestamptz,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

-- Create shopping_items table
CREATE TABLE IF NOT EXISTS shopping_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  list_id uuid REFERENCES shopping_lists(id) ON DELETE CASCADE NOT NULL,
  product_type text NOT NULL,
  product_name text NOT NULL,
  brand text,
  quantity_value double precision NOT NULL,
  unit_price_cents integer NOT NULL,
  is_wholesale boolean DEFAULT false NOT NULL,
  is_weight_based boolean DEFAULT false NOT NULL,
  price_per_kg_cents integer,
  weight_kg double precision,
  photo_url text,
  photo_captured_at timestamptz,
  substitute_item_id uuid REFERENCES shopping_items(id) ON DELETE SET NULL,
  position integer NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL
);

-- Create purchases table
CREATE TABLE IF NOT EXISTS purchases (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  list_id uuid REFERENCES shopping_lists(id) ON DELETE SET NULL,
  market_name text,
  total_amount_cents integer NOT NULL,
  budget_goal_cents integer,
  exceeded_budget boolean DEFAULT false NOT NULL,
  completed_at timestamptz DEFAULT now() NOT NULL
);

-- Create purchase_items table
CREATE TABLE IF NOT EXISTS purchase_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_id uuid REFERENCES purchases(id) ON DELETE CASCADE NOT NULL,
  product_type text NOT NULL,
  product_name text NOT NULL,
  quantity_value double precision NOT NULL,
  unit_price_cents integer NOT NULL,
  total_price_cents integer NOT NULL
);

-- Enable Row Level Security (RLS) on all tables
ALTER TABLE shopping_lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_items ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "users_own_lists" ON shopping_lists FOR ALL
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_own_items" ON shopping_items FOR ALL
  USING (EXISTS (
    SELECT 1 FROM shopping_lists
    WHERE shopping_lists.id = shopping_items.list_id AND shopping_lists.user_id = auth.uid()
  )) WITH CHECK (EXISTS (
    SELECT 1 FROM shopping_lists
    WHERE shopping_lists.id = shopping_items.list_id AND shopping_lists.user_id = auth.uid()
  ));

CREATE POLICY "users_own_purchases" ON purchases FOR ALL
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_own_purchase_items" ON purchase_items FOR ALL
  USING (EXISTS (
    SELECT 1 FROM purchases
    WHERE purchases.id = purchase_items.purchase_id AND purchases.user_id = auth.uid()
  )) WITH CHECK (EXISTS (
    SELECT 1 FROM purchases
    WHERE purchases.id = purchase_items.purchase_id AND purchases.user_id = auth.uid()
  ));

-- Create transaction RPC for finalizing a purchase
CREATE OR REPLACE FUNCTION finalize_purchase(p_list_id uuid)
RETURNS uuid AS $$
DECLARE
  v_purchase_id uuid;
  v_user_id uuid;
  v_market_name text;
  v_total_amount_cents integer;
  v_budget_goal_cents integer;
  v_exceeded_budget boolean;
BEGIN
  -- Get list details and verify ownership
  SELECT user_id, market_name, budget_goal_cents
  INTO v_user_id, v_market_name, v_budget_goal_cents
  FROM shopping_lists
  WHERE id = p_list_id AND user_id = auth.uid();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Lista não encontrada ou sem permissão';
  END IF;

  -- Calculate total amount cents
  SELECT COALESCE(SUM(
    CASE 
      WHEN is_weight_based THEN CAST(price_per_kg_cents * weight_kg AS integer)
      ELSE CAST(unit_price_cents * quantity_value AS integer)
    END
  ), 0)
  INTO v_total_amount_cents
  FROM shopping_items
  WHERE list_id = p_list_id;

  -- Check if exceeded budget
  v_exceeded_budget := (v_budget_goal_cents IS NOT NULL) AND (v_total_amount_cents > v_budget_goal_cents);

  -- Insert into purchases
  v_purchase_id := gen_random_uuid();
  INSERT INTO purchases (id, user_id, list_id, market_name, total_amount_cents, budget_goal_cents, exceeded_budget, completed_at)
  VALUES (v_purchase_id, v_user_id, p_list_id, v_market_name, v_total_amount_cents, v_budget_goal_cents, v_exceeded_budget, now());

  -- Insert items into purchase_items
  INSERT INTO purchase_items (id, purchase_id, product_type, product_name, quantity_value, unit_price_cents, total_price_cents)
  SELECT 
    gen_random_uuid(),
    v_purchase_id,
    product_type,
    product_name,
    quantity_value,
    unit_price_cents,
    CASE 
      WHEN is_weight_based THEN CAST(price_per_kg_cents * weight_kg AS integer)
      ELSE CAST(unit_price_cents * quantity_value AS integer)
    END
  FROM shopping_items
  WHERE list_id = p_list_id;

  -- Update shopping list status
  UPDATE shopping_lists 
  SET is_completed = true, completed_at = now(), updated_at = now()
  WHERE id = p_list_id;

  RETURN v_purchase_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
