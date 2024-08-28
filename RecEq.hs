{-# LANGUAGE BangPatterns #-}
{-# OPTIONS_GHC -Wno-incomplete-patterns #-}
{-# OPTIONS_GHC -Wno-incomplete-uni-patterns #-}
{-# OPTIONS_GHC -Wno-missing-signatures #-}
{-# OPTIONS_GHC -Wno-unused-top-binds #-}

module RecEq
  (
  )
where

data Expr
  = Num Double
  | Var String
  | If Expr Expr Expr
  | Call String ![Expr]
  | Op String ![Expr]
  deriving (Show, Eq)

lookUpFunc target (n : ns, f : fs) = if n == target then f else lookUpFunc target (ns, fs)

lookUpV _ ([], []) = Num 0
lookUpV target (!n : ns, !v : vs) = if n == target then v else lookUpV target (ns, vs)

-- because we have already evaluated args
-- we need no more eval here ⬇️
evalV (Var x) env _ = lookUpV x env
evalV (Call f args_) env pgm =
  --  Call-by-value  eval args first
  let args = evlistV args_ env pgm
      (params, body) = lookUpFunc f pgm
   in evalV body (params, args) pgm
evalV (Op oper [left_, right_]) env pgm = case (evalV left_ env pgm, evalV right_ env pgm) of
  (Num left, Num right) -> case oper of
    "+" -> Num $ left + right
    "-" -> Num $ left - right
    "<=" -> Num $ if left <= right then 1 else 0
    _ -> error "Unknown oper!"
  (left, right) -> Op oper [left, right]
evalV (If cond true false) env pgm =
  case evalV cond env pgm of
    Num 1 -> evalV true env pgm
    _ -> evalV false env pgm
evalV x _ _ = x

evlistV [] _ _ = []
evlistV (e : es) env pgm = evalV e env pgm : evlistV es env pgm

lookUpN _ ([], []) = Num 0
lookUpN target (n : ns, v : vs) = if n == target then v else lookUpN target (ns, vs)

subs env (Var x) = lookUpN x env
subs env (Call f args) = Call f (map (subs env) args)
subs env (Op oper exprs) = Op oper (map (subs env) exprs)
subs env (If cond true false) = If (subs env cond) (subs env true) (subs env false)
subs _ e = e

-- Because we havent eval args, we must eval it when we get it
evalN (Var x) env pgm = evalN (lookUpN x env) env pgm
evalN (Call f args_) env pgm =
  --  Call-by-name  Dont eval, only substitute args
  let args = subsList args_ env
      (params, body) = lookUpFunc f pgm
   in evalN body (params, args) pgm
evalN (Op oper [left_, right_]) env pgm = case (evalN left_ env pgm, evalN right_ env pgm) of
  (Num left, Num right) -> case oper of
    "+" -> Num $ left + right
    "-" -> Num $ left - right
    "<=" -> Num $ if left <= right then 1 else 0
    _ -> error "Unknown oper!"
  (left, right) -> Op oper [left, right]
evalN (If cond true false) env pgm =
  case evalN cond env pgm of
    Num 1 -> evalN true env pgm
    _ -> evalN false env pgm
evalN x _ _ = x

subsList [] _ = []
subsList (e : es) env = subs env e : subsList es env

interpretV pgm args =
  let (_, (params, body) : _) = pgm
   in evalV body (params, args) pgm

interpretN pgm args =
  let (_, (params, body) : _) = pgm
   in evalN body (params, args) pgm

h = (["h"], [(["x", "y"], If (Op "<=" [Var "y", Num 1]) (Var "y") (Call "h" [Call "h" [Op "+" [Var "x", Num 1], Var "y"], Op "-" [Var "y", Num 2]]))])

mainN = interpretN h [Num 3, Num 5]

mainV = interpretV h [Num 3, Num 5]

-- pgm = (["main", "plus"], [(["a", "b"], Call "plus" [Var "a", Var "b"]), (["a", "b"], Op "+" [Var "a", Var "b"])])
